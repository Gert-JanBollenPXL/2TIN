import { test, describe, before, after } from 'node:test';
import assert from 'node:assert';
import { buildApp } from '../../server.js';

describe('API CORS Tests', () => {
  let app;

  before(async () => {
    // Mock config with restricted origins
    // Note: We need to override process.env BEFORE buildApp is called if logic is inside buildApp
    // But our server.js reads process.env inside the function body? 
    // Wait, the logic I added:
    // const allowedOrigins = (process.env.CORS_ALLOWED_ORIGINS || '').split(',')
    // is executed inside buildApp() if I refactored it correctly?
    // Let's check server.js content.
    
    process.env.CORS_ALLOWED_ORIGINS = 'http://allowed.com';
    process.env.NODE_ENV = 'production'; // Enforce strict check
    
    app = await buildApp({ 
        dbPool: { query: async () => ({ rows: [] }), connect: async () => ({ release: () => {} }) },
        fetch: async () => ({})
    });
  });

  after(async () => {
    await app.close();
    process.env.NODE_ENV = 'test';
  });

  test('CORS: Allows requests from allowed origin', async () => {
    const response = await app.inject({
      method: 'OPTIONS',
      url: '/health',
      headers: {
        'Origin': 'http://allowed.com',
        'Access-Control-Request-Method': 'GET'
      }
    });
    
    assert.strictEqual(response.statusCode, 204);
    assert.strictEqual(response.headers['access-control-allow-origin'], 'http://allowed.com');
  });

  test('CORS: Blocks requests from disallowed origin', async () => {
    const response = await app.inject({
      method: 'OPTIONS',
      url: '/health',
      headers: {
        'Origin': 'http://evil.com',
        'Access-Control-Request-Method': 'GET'
      }
    });
    
    // Fastify cors plugin returns error for blocked origin, usually 500 or 403 depending on config.
    // The default behavior for "origin" callback returning error is that the request fails.
    // However, for OPTIONS, it might return 200 but WITHOUT the CORS headers, or return an error.
    // Let's check headers.
    
    // Actually, checking the callback implementation: cb(new Error("Not allowed by CORS"), false)
    // This usually results in a 500 Internal Server Error in Fastify unless handled.
    
    assert.notStrictEqual(response.headers['access-control-allow-origin'], 'http://evil.com');
  });
});
