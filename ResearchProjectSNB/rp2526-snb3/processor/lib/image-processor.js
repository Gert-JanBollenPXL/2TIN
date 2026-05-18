import { spawn as defaultSpawn } from 'child_process';
import { promises as fs } from 'fs';

export class ImageProcessor {
  constructor(logger, spawnFn) {
    this.logger = logger || console;
    this.spawn = spawnFn || defaultSpawn;
  }

  getOptimalScale(fileSizeBytes) {
    if (fileSizeBytes > 10 * 1024 * 1024) return '1280x720';
    if (fileSizeBytes > 2 * 1024 * 1024) return '1600x900';
    return '1920x1080';
  }

  async process(inputPath, outputPath, options = {}) {
    const fileStats = await fs.stat(inputPath);
    const scale = this.getOptimalScale(fileStats.size);
    
    return new Promise((resolve, reject) => {
      const args = [inputPath, '-o', outputPath];
      
      const method = options.method || 'mosaic';
      args.push('--replacewith', method);
      
      if (method === 'mosaic' && options.mosaic_size) {
        args.push('--mosaicsize', options.mosaic_size.toString());
      }
      
      args.push('--scale', scale);
      
      this.logger.info('Running deface', { args: args.join(' ') });
      
      const deface = this.spawn('/opt/deface-env/bin/deface', args);
      
      let stderr = '';
      deface.stderr.on('data', (data) => stderr += data.toString());
      
      deface.on('close', (code, signal) => {
        if (code === 0) {
          resolve({ success: true, output: outputPath, stderr });
        } else {
          reject(new Error(`deface failed: ${stderr || signal}`));
        }
      });
      
      deface.on('error', (err) => reject(new Error(`Failed to spawn deface: ${err.message}`)));
    });
  }
}
