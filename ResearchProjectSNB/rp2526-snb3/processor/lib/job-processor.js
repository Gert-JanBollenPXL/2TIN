import path from 'path';
import { randomUUID } from 'crypto';

export class JobProcessor {
  constructor(dependencies) {
    this.db = dependencies.db;
    this.fileService = dependencies.fileService;
    this.imageProcessor = dependencies.imageProcessor;
    this.config = dependencies.config;
    this.logger = dependencies.logger || console;
    this.fs = dependencies.fs; // Injected fs
  }

  async processJob(job) {
    // Note: We expect the caller to handle the DB transaction/connection release if needed
    // But here we might need to query image details
    
    try {
      // 1. Get image details
      const imageResult = await this.db.query(
        'SELECT original_path, mime, bytes, processing_options FROM images WHERE id = $1',
        [job.image_id]
      );
      
      if (imageResult.rows.length === 0) {
        throw new Error('Image not found');
      }
      
      const image = imageResult.rows[0];
      
      // 2. Prepare paths
      const tempId = randomUUID();
      const ext = path.extname(image.original_path);
      const tempInput = path.join(this.config.tempDir, `${tempId}-input${ext}`);
      const tempOutput = path.join(this.config.tempDir, `${tempId}-output${ext}`);
      const processedPath = image.original_path.replace('originals/', 'processed/');
      
      try {
        // 3. Download
        await this.fileService.download(image.original_path, tempInput);
        
        // Use injected fs
        try {
            const inputStats = await this.fs.stat(tempInput);
            this.logger.info('Downloaded file', { size: inputStats.size });
        } catch (e) {
            // Ignore stat error if mock fs doesn't strictly support it
        }
        
        // 4. Process
        const processingOptions = job.processing_options || image.processing_options || {};
        await this.imageProcessor.process(tempInput, tempOutput, processingOptions);
        
        // 5. Upload
        await this.fileService.upload(tempOutput, processedPath);
        
        // 6. Complete Job
        await this.db.query('SELECT complete_job($1, $2)', [job.id, processedPath]);
        
      } finally {
        // Cleanup with injected fs
        try {
          await this.fs.unlink(tempInput);
          await this.fs.unlink(tempOutput);
        } catch (e) { /* ignore */ }
      }
      
    } catch (error) {
      this.logger.error('Job failed', { jobId: job.id, error: error.message });
      await this.db.query('SELECT fail_job($1, $2)', [job.id, error.message]);
      throw error; // Re-throw to let worker know
    }
  }
}
