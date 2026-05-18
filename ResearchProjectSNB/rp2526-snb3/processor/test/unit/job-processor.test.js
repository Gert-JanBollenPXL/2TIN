import { test, describe } from 'node:test';
import assert from 'node:assert';
import { JobProcessor } from '../../lib/job-processor.js';

describe('JobProcessor Unit Tests', () => {
  const mockConfig = { tempDir: '/tmp/test' };
  const mockLogger = { info: () => {}, error: () => {}, warn: () => {} };
  
  test('processJob executes full pipeline successfully', async () => {
    // 1. Mock DB
    const mockDb = {
      query: async (text, params) => {
        if (text.includes('SELECT original_path')) {
          return {
            rows: [{
              original_path: 'originals/test.jpg',
              mime: 'image/jpeg',
              bytes: 1024,
              processing_options: { method: 'blur' }
            }]
          };
        }
        if (text.includes('complete_job')) {
          return { rows: [] };
        }
        throw new Error(`Unexpected query: ${text}`);
      }
    };

    // 2. Mock FileService
    const mockFileService = {
      download: async (path, dest) => { /* no-op */ },
      upload: async (src, dest) => { /* no-op */ }
    };

    // 3. Mock ImageProcessor
    const mockImageProcessor = {
      process: async (input, output, options) => {
        assert.strictEqual(options.method, 'blur');
        return { success: true };
      }
    };

    // 4. Mock FS
    const mockFs = {
        stat: async () => ({ size: 1024 }),
        unlink: async () => {}
    };

    const processor = new JobProcessor({
      db: mockDb,
      fileService: mockFileService,
      imageProcessor: mockImageProcessor,
      config: mockConfig,
      logger: mockLogger,
      fs: mockFs
    });

    const job = { id: 1, image_id: 'mock-uuid' };
    await processor.processJob(job);
    
    // If we get here without throwing, success
    assert.ok(true);
  });
});