import { test, describe, before, after } from 'node:test';
import assert from 'node:assert';
import { buildApp } from '../../server.js';

describe('API Unit Tests (User Scoping)', () => {
  let app;
  let mockPool;
  let queries;

  before(async () => {
    queries = [];
    mockPool = {
      query: async (text, params) => {
        queries.push({ text, params });
        if (text.includes('SELECT id, status')) return { rows: [] };
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

    const mockFetch = async (url) => {
      if (url.includes('/sign')) {
        return {
          json: async () => ({ url: '/signed-path', headers: {} })
        };
      }
      return { ok: true, json: async () => ({}) };
    };

    app = await buildApp({
      dbPool: mockPool,
      fetch: mockFetch,
      config: {
        authUserHeaders: ['x-auth-request-email'],
        authUserFallback: 'shared'
      }
    });
  });

  after(async () => {
    await app.close();
  });

  test('POST /upload-init uses auth header for user scoping', async () => {
    queries.length = 0;
    await app.inject({
      method: 'POST',
      url: '/upload-init',
      headers: { 'x-auth-request-email': 'alice@example.com' },
      payload: {
        filename: 'a.png',
        mime: 'image/png',
        bytes: 100,
        sha256: 'a',
        processing_options: {}
      }
    });

    const duplicateQuery = queries.find(({ text }) => text.includes('SELECT id, status'));
    assert.ok(duplicateQuery, 'Expected duplicate check query');
    assert.ok(duplicateQuery.text.includes('user_id'), 'Expected user_id filter');
    assert.strictEqual(duplicateQuery.params[1], 'alice@example.com');
  });

  test('POST /upload-init falls back to shared user when header is missing', async () => {
    queries.length = 0;
    await app.inject({
      method: 'POST',
      url: '/upload-init',
      payload: {
        filename: 'a.png',
        mime: 'image/png',
        bytes: 100,
        sha256: 'b',
        processing_options: {}
      }
    });

    const duplicateQuery = queries.find(({ text }) => text.includes('SELECT id, status'));
    assert.ok(duplicateQuery, 'Expected duplicate check query');
    assert.strictEqual(duplicateQuery.params[1], 'shared');
  });

  test('GET /images scopes by user header', async () => {
    queries.length = 0;
    await app.inject({
      method: 'GET',
      url: '/images',
      headers: { 'x-auth-request-email': 'bob@example.com' }
    });

    const listQuery = queries.find(({ text }) => text.includes('FROM images'));
    assert.ok(listQuery, 'Expected list images query');
    assert.ok(listQuery.text.includes('WHERE user_id = $1'), 'Expected user_id filter');
    assert.strictEqual(listQuery.params[0], 'bob@example.com');
  });
});
