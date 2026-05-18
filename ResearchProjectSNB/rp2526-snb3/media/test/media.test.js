import { test, describe, before } from 'node:test';
import assert from 'node:assert';
import { app } from '../server.js';
import { createHmac } from 'crypto';

describe('Media Service Tests', () => {
  before(async () => {
    await app.ready();
  });

  test('GET /health returns status 200', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/health'
    });
    assert.strictEqual(response.statusCode, 200);
    const body = JSON.parse(response.body);
    assert.strictEqual(body.status, 'ok');
  });

  test('POST /sign generates valid signature', async () => {
    const path = '/test-image.jpg';
    const method = 'GET';
    const expiresIn = 300;
    
    const response = await app.inject({
      method: 'POST',
      url: '/sign',
      payload: { method, path, expiresIn }
    });
    
    assert.strictEqual(response.statusCode, 200);
    const body = JSON.parse(response.body);
    assert.strictEqual(body.url, path);
    assert.ok(body.headers['X-Signature']);
    assert.ok(body.headers['X-Expires']);

    // Verify the signature manually
    const secret = process.env.MEDIA_SIGNING_SECRET || 'dev-secret-change-in-production';
    const expected = createHmac('sha256', secret)
      .update(`${method}:${path}:${body.headers['X-Expires']}`)
      .digest('hex');
    
    assert.strictEqual(body.headers['X-Signature'], expected);
  });
});
