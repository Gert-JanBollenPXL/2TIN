import { test, describe } from 'node:test';
import assert from 'node:assert';
import { ImageProcessor } from '../../lib/image-processor.js';
import EventEmitter from 'events';
import fs from 'fs/promises';

describe('ImageProcessor Spawn Tests', () => {
  test('process() spawns deface correctly', async () => {
    const mockLogger = { info: () => {} };
    
    // Create a dummy input file so fs.stat works (ImageProcessor calls fs.stat)
    await fs.writeFile('test_input.jpg', 'dummy');

    let spawnCalled = false;
    const mockSpawn = (cmd, args) => {
      spawnCalled = true;
      assert.strictEqual(cmd, '/opt/deface-env/bin/deface');
      assert.ok(args.includes('mosaic'));
      
      const proc = new EventEmitter();
      proc.stderr = new EventEmitter();
      
      // Simulate success on next tick
      process.nextTick(() => {
        proc.emit('close', 0, null);
      });
      
      return proc;
    };

    const processor = new ImageProcessor(mockLogger, mockSpawn);
    
    try {
        await processor.process('test_input.jpg', 'test_output.jpg', { method: 'mosaic' });
        assert.ok(spawnCalled);
    } finally {
        await fs.unlink('test_input.jpg').catch(() => {});
    }
  });
});