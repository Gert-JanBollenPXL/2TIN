import { test, describe, before, after } from 'node:test';
import assert from 'node:assert';
import { buildApp } from '../../server.js';

describe('API Unit Tests (Mocked DB)', () => {
  let app;
  let mockPool;

  before(async () => {
    // Mock DB Pool
    mockPool = {
      query: async (text, params) => {
        if (text.includes('SELECT 1')) return { rows: [{ '?column?': 1 }] };
        if (text.includes('SELECT id, status')) return { rows: [] }; // No duplicate
        if (text.includes('INSERT INTO images')) return { rows: [{ id: 'mock-uuid' }] };
        if (text.includes('INSERT INTO events')) return { rows: [] };
        return { rows: [] };
      },
      connect: async () => ({
        query: async () => ({ rows: [] }),
        release: () => {}
      }),
      end: async () => {}
    };

    // Mock Fetch
    const mockFetch = async (url) => {
      if (url.includes('/sign')) {
        return {
            json: async () => ({ url: '/signed-path', headers: {} })
        };
      }
      return { ok: true, json: async () => ({}) };
    };

    app = await buildApp({ dbPool: mockPool, fetch: mockFetch });
  });

  after(async () => {
    await app.close();
  });

  test('GET /health returns 200 via mock DB', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/health'
    });
    assert.strictEqual(response.statusCode, 200);
    const body = JSON.parse(response.body);
    assert.strictEqual(body.database, 'connected');
  });

  test('POST /upload-init validates inputs', async () => {
    // Invalid MIME
    const res1 = await app.inject({
      method: 'POST',
      url: '/upload-init',
      payload: { filename: 'a.exe', mime: 'application/exe', bytes: 100, sha256: 'a', processing_options: {} }
    });
    assert.strictEqual(res1.statusCode, 400);

    // Invalid Method
    const res2 = await app.inject({
      method: 'POST',
      url: '/upload-init',
      payload: { filename: 'a.png', mime: 'image/png', bytes: 100, sha256: 'a', processing_options: { method: 'bad' } }
    });
    assert.strictEqual(res2.statusCode, 400);

    // Invalid Mosaic Size
    const res3 = await app.inject({
      method: 'POST',
      url: '/upload-init',
      payload: { filename: 'a.png', mime: 'image/png', bytes: 100, sha256: 'a', processing_options: { method: 'mosaic', mosaic_size: 999 } }
    });
    assert.strictEqual(res3.statusCode, 400);
  });

  test('POST /images/:id/process creates job', async () => {
    // Mock DB to return image and then insert job
    mockPool.query = async (text) => {
      if (text.includes('SELECT status')) return { rows: [{ status: 'uploaded', sha256: 'hash', processing_options: {} }] };
      if (text.includes('SELECT id FROM jobs')) return { rows: [] }; // No duplicate job
      if (text.includes('INSERT INTO jobs')) return { rows: [{ id: 'job-1' }] };
      if (text.includes('INSERT INTO events')) return { rows: [] };
      if (text.includes('UPDATE images')) return { rows: [] };
      return { rows: [] };
    };

    const response = await app.inject({
      method: 'POST',
      url: '/images/img-1/process',
      payload: { pipeline: 'deface' }
    });

    assert.strictEqual(response.statusCode, 200);
    const body = JSON.parse(response.body);
    assert.strictEqual(body.job_id, 'job-1');
  });
});
