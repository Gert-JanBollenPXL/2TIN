import { test, describe, before, after } from 'node:test';
import assert from 'node:assert';
import { app } from '../server.js';
import { createHmac } from 'crypto';
import fs from 'fs';
import path from 'path';

describe('Media Service Routes', () => {
  const secret = process.env.MEDIA_SIGNING_SECRET || 'dev-secret-change-in-production';
  const testDir = path.join(process.cwd(), 'test-media-root');

  before(async () => {
    // Override config via env var hack? Too late, module loaded.
    // Ideally we'd refactor server.js like api. 
    // But since server.js uses process.env.MEDIA_ROOT || ..., 
    // we can't easily change it after import unless we refactor.
    // For now, let's just use the default path or mocked one if possible.
    // Actually, let's just test the logic.
    await app.ready();
  });

  function sign(method, path, expiresIn = 300) {
    const expires = Date.now() + (expiresIn * 1000);
    const signature = createHmac('sha256', secret)
      .update(`${method}:${path}:${expires}`)
      .digest('hex');
    return { 'X-Signature': signature, 'X-Expires': expires };
  }

  test('PUT /originals/test.jpg rejects invalid signature', async () => {
    const res = await app.inject({
      method: 'PUT',
      url: '/originals/test.jpg',
      headers: { 'X-Signature': 'bad', 'X-Expires': Date.now() + 1000 }
    });
    assert.strictEqual(res.statusCode, 403);
  });

  test('PUT /originals/test.jpg accepts valid signature', async () => {
    const headers = sign('PUT', '/originals/test.jpg');
    headers['Content-Type'] = 'image/jpeg';
    const res = await app.inject({
      method: 'PUT',
      url: '/originals/test.jpg',
      headers,
      payload: Buffer.from('file-content')
    });
    // It tries to write to disk. 
    // Since we didn't mock fs, it writes to media-data/originals/test.jpg
    // This is fine for now, we'll clean up.
    assert.strictEqual(res.statusCode, 200);
  });

  test('GET /originals/test.jpg retrieves file', async () => {
    const headers = sign('GET', '/originals/test.jpg');
    const res = await app.inject({
      method: 'GET',
      url: '/originals/test.jpg',
      headers
    });
    assert.strictEqual(res.statusCode, 200);
    assert.strictEqual(res.body, 'file-content');
  });

  test('DELETE /originals/test.jpg deletes file', async () => {
    const headers = sign('DELETE', '/originals/test.jpg');
    const res = await app.inject({
      method: 'DELETE',
      url: '/originals/test.jpg',
      headers
    });
    assert.strictEqual(res.statusCode, 200);
  });
});
