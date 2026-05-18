import pg from 'pg';
import { promises as fs } from 'fs';
import { randomUUID } from 'crypto';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

import { FileService } from './lib/file-service.js';
import { ImageProcessor } from './lib/image-processor.js';
import { JobProcessor } from './lib/job-processor.js';

dotenv.config();

// Logger
const logger = {
  info: (msg, data = {}) => console.log(JSON.stringify({ timestamp: new Date().toISOString(), level: 'info', msg, ...data })),
  error: (msg, data = {}) => console.error(JSON.stringify({ timestamp: new Date().toISOString(), level: 'error', msg, ...data })),
  warn: (msg, data = {}) => console.warn(JSON.stringify({ timestamp: new Date().toISOString(), level: 'warn', msg, ...data }))
};

// Config
const config = {
  databaseUrl: process.env.DATABASE_URL || 'postgresql://pxlcensor:devpassword@localhost:5432/pxlcensor',
  mediaServiceUrl: process.env.MEDIA_SERVICE_URL || 'http://localhost:8081',
  mediaSigningSecret: process.env.MEDIA_SIGNING_SECRET || 'dev-secret-change-in-production',
  concurrency: parseInt(process.env.PROCESSOR_CONCURRENCY || '1'),
  workerId: `worker-${process.env.HOSTNAME || randomUUID().slice(0, 8)}`,
  tempDir: process.env.TEMP_DIR || '/tmp/pxlcensor'
};

// Dependencies
const pool = new pg.Pool({ connectionString: config.databaseUrl, max: config.concurrency + 2 });
const fileService = new FileService(config);
const imageProcessor = new ImageProcessor(logger);

// Ensure temp dir
await fs.mkdir(config.tempDir, { recursive: true });

async function worker() {
  logger.info('Worker starting', { workerId: config.workerId });
  
  const listenClient = await pool.connect();
  
  listenClient.on('notification', () => processNext());
  await listenClient.query('LISTEN jobs_channel');
  
  const activeJobs = new Set();
  
  async function processNext() {
    if (activeJobs.size >= config.concurrency) return;
    
    try {
      const result = await pool.query('SELECT * FROM claim_jobs($1, $2)', [config.workerId, 1]);
      
      if (result.rows.length > 0) {
        const job = result.rows[0];
        activeJobs.add(job.id);
        logger.info('Claimed job', { jobId: job.id });
        
        // Create a new client for the job transaction/processing to avoid blocking the listener
        const jobClient = await pool.connect();
        
        const jobProcessor = new JobProcessor({
          db: jobClient,
          fileService,
          imageProcessor,
          config,
          logger,
          fs // Pass real fs
        });
        
        jobProcessor.processJob(job)
          .catch(err => { /* Error logged in processJob */ })
          .finally(() => {
            jobClient.release();
            activeJobs.delete(job.id);
            processNext();
          });
      }
    } catch (err) {
      logger.error('Error claiming job', { error: err.message });
    }
  }
  
  processNext();
  setInterval(() => { if (activeJobs.size < config.concurrency) processNext(); }, 10000);
  
  // Graceful shutdown
  process.on('SIGTERM', async () => {
    await listenClient.query('UNLISTEN jobs_channel');
    while (activeJobs.size > 0) await new Promise(r => setTimeout(r, 1000));
    await listenClient.release();
    await pool.end();
    process.exit(0);
  });
}

// Start if main
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  worker().catch(err => {
    logger.error('Fatal error', { error: err.message });
    process.exit(1);
  });
}

export { worker, config };