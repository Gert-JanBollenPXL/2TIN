import { test, after, describe, before } from 'node:test';
import assert from 'node:assert';
import { app, pool } from '../../server.js';

after(async () => {
  await pool.end();
});

describe('API Integration Tests', () => {
  // We need to wait for the app to be ready
  before(async () => {
    await app.ready();
  });

  test('GET /health returns status 200 (or 503 if DB down)', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/health'
    });
    // It might be 503 if we don't have a DB running, but the server should respond.
    // The health check endpoint in server.js returns { status: 'error' } but defaults to 200 OK unless we throw?
    // Let's check server.js code:
    // app.get('/health', async () => { try { await pool.query... return {status:'ok'} } catch { return {status:'error'} } })
    // Fastify returns 200 by default for returned objects.
    assert.strictEqual(response.statusCode, 200);
    const body = JSON.parse(response.body);
    assert.ok(body.status === 'ok' || body.status === 'error');
  });

  test('GET /metrics returns Prometheus metrics', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/metrics'
    });
    assert.strictEqual(response.statusCode, 200);
    // fastify-metrics usually returns text/plain
    assert.ok(response.body.includes('# HELP'), 'Metrics should contain help text');
    assert.ok(response.body.includes('http_request_duration_seconds'), 'Metrics should contain HTTP duration');
  });
  
  test('POST /upload-init validates invalid mime type', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/upload-init',
      payload: {
        filename: 'test.exe',
        mime: 'application/x-msdownload',
        bytes: 1024,
        sha256: 'fakehash',
        processing_options: {}
      }
    });
    assert.strictEqual(response.statusCode, 400);
    const body = JSON.parse(response.body);
    assert.strictEqual(body.message, 'Invalid file type');
  });
});

describe('API HTTPS URL Generation', () => {
  let httpsApp;
  let testPool;

  before(async () => {
    // Mock fetch so we don't need a live media service
    const mockFetch = async (url) => {
      const urlPath = new URL(url).pathname;
      if (urlPath === '/sign') {
        return {
          url: '/originals/some-path.jpg',
          headers: { 'X-Signature': 'test-sig' }
        };
      }
      return { status: 404 };
    };
    
    // Import buildApp and create a new app instance with custom config
    const { buildApp } = await import('../../server.js');
    const { default: pg } = await import('pg');
    
    testPool = new pg.Pool({ connectionString: process.env.DATABASE_URL || 'postgresql://pxlcensor:devpassword@localhost:5432/pxlcensor' });

    httpsApp = await buildApp({
      fetch: mockFetch,
      dbPool: testPool, // Use a dedicated pool for this test suite
      config: {
        apiExternalUrl: 'https://pxlcensor.test.com',
        mediaServiceUrl: 'http://media-service.internal:8081'
      }
    });
    await httpsApp.ready();
  });

  after(async () => {
    await httpsApp.close();
    await testPool.end();
  });

  test('POST /upload-init returns https upload_url', async () => {
    // First, ensure an image record exists to avoid duplicate=true short-circuit
    const sha = 'a'.repeat(64);
    await testPool.query('DELETE FROM images WHERE sha256 = $1', [sha]);
    
    const response = await httpsApp.inject({
      method: 'POST',
      url: '/upload-init',
      payload: {
        filename: 'test.jpg',
        mime: 'image/jpeg',
        bytes: 1024,
        sha256: sha,
        processing_options: {}
      }
    });

    assert.strictEqual(response.statusCode, 200, `Response was ${response.statusCode}, body: ${response.body}`);
    const body = JSON.parse(response.body);

    assert.ok(body.upload_url.startsWith('https://pxlcensor.test.com:8081/'), `URL was ${body.upload_url}`);
  });

  test('GET /images/:id returns https original_url and processed_url', async () => {
    // Create a dummy image record
    const sha = 'b'.repeat(64);
    const res = await testPool.query(
      `INSERT INTO images (original_path, processed_path, sha256, mime, bytes, status)
       VALUES ('originals/test.jpg', 'processed/test.jpg', $1, 'image/jpeg', 100, 'done')
       RETURNING id`,
      [sha]
    );
    const imageId = res.rows[0].id;

    const response = await httpsApp.inject({
      method: 'GET',
      url: `/images/${imageId}`,
      headers: { 'content-type': 'application/json' }
    });

    assert.strictEqual(response.statusCode, 200);
    const body = JSON.parse(response.body);

    assert.ok(body.original_url.startsWith('https://pxlcensor.test.com:8081/'), `Original URL was ${body.original_url}`);
    assert.ok(body.processed_url.startsWith('https://pxlcensor.test.com:8081/'), `Processed URL was ${body.processed_url}`);

    // Clean up
    await testPool.query('DELETE FROM images WHERE id = $1', [imageId]);
  });
});

describe('API User Scoping', () => {
  before(async () => {
    await pool.query("ALTER TABLE images ADD COLUMN IF NOT EXISTS user_id TEXT NOT NULL DEFAULT 'shared'");
    await pool.query("ALTER TABLE images ADD COLUMN IF NOT EXISTS processing_options JSONB DEFAULT '{\"method\": \"mosaic\", \"scale_720p\": false, \"mosaic_size\": 20}'");
    await pool.query("ALTER TABLE jobs ADD COLUMN IF NOT EXISTS processing_options JSONB DEFAULT '{}'");
  });

  test('GET /images only returns images for the current user', async () => {
    const res1 = await pool.query(
      `INSERT INTO images (original_path, processed_path, sha256, mime, bytes, status, user_id)
       VALUES ('originals/a.jpg', 'processed/a.jpg', $1, 'image/jpeg', 100, 'done', $2)
       RETURNING id`,
      ['c'.repeat(64), 'alice@example.com']
    );
    const res2 = await pool.query(
      `INSERT INTO images (original_path, processed_path, sha256, mime, bytes, status, user_id)
       VALUES ('originals/b.jpg', 'processed/b.jpg', $1, 'image/jpeg', 100, 'done', $2)
       RETURNING id`,
      ['d'.repeat(64), 'bob@example.com']
    );

    const aliceId = res1.rows[0].id;
    const bobId = res2.rows[0].id;

    try {
      const response = await app.inject({
        method: 'GET',
        url: '/images',
        headers: { 'x-auth-request-email': 'alice@example.com' }
      });

      assert.strictEqual(response.statusCode, 200);
      const body = JSON.parse(response.body);
      assert.strictEqual(body.images.length, 1);
      assert.strictEqual(body.images[0].id, aliceId);
    } finally {
      await pool.query('DELETE FROM images WHERE id = $1', [aliceId]);
      await pool.query('DELETE FROM images WHERE id = $1', [bobId]);
    }
  });

  test('GET /images/:id returns 404 for mismatched user', async () => {
    const res = await pool.query(
      `INSERT INTO images (original_path, processed_path, sha256, mime, bytes, status, user_id)
       VALUES ('originals/c.jpg', 'processed/c.jpg', $1, 'image/jpeg', 100, 'done', $2)
       RETURNING id`,
      ['e'.repeat(64), 'charlie@example.com']
    );

    const imageId = res.rows[0].id;

    try {
      const response = await app.inject({
        method: 'GET',
        url: `/images/${imageId}`,
        headers: { 'x-auth-request-email': 'alice@example.com' }
      });

      assert.strictEqual(response.statusCode, 404);
    } finally {
      await pool.query('DELETE FROM images WHERE id = $1', [imageId]);
    }
  });

  test('GET /images falls back to shared user when no header is present', async () => {
    const res = await pool.query(
      `INSERT INTO images (original_path, processed_path, sha256, mime, bytes, status, user_id)
       VALUES ('originals/shared.jpg', 'processed/shared.jpg', $1, 'image/jpeg', 100, 'done', $2)
       RETURNING id`,
      ['f'.repeat(64), 'shared']
    );

    const sharedId = res.rows[0].id;

    try {
      const response = await app.inject({
        method: 'GET',
        url: '/images'
      });

      assert.strictEqual(response.statusCode, 200);
      const body = JSON.parse(response.body);
      assert.ok(body.images.some((image) => image.id === sharedId));
    } finally {
      await pool.query('DELETE FROM images WHERE id = $1', [sharedId]);
    }
  });
});
