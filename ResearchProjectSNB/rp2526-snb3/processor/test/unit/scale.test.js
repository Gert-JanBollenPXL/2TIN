import { test, describe } from 'node:test';
import assert from 'node:assert';
import { ImageProcessor } from '../../lib/image-processor.js';

describe('ImageProcessor Unit Tests', () => {
  const processor = new ImageProcessor();

  test('getOptimalScale returns correct resolution for file sizes', () => {
    // Small (<2MB)
    assert.strictEqual(processor.getOptimalScale(1024 * 1024), '1920x1080');
    
    // Medium (2-10MB)
    assert.strictEqual(processor.getOptimalScale(5 * 1024 * 1024), '1600x900');
    
    // Large (>10MB)
    assert.strictEqual(processor.getOptimalScale(15 * 1024 * 1024), '1280x720');
  });
});