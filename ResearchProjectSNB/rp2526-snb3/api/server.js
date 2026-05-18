import Fastify from 'fastify';
import cors from '@fastify/cors';
import sensible from '@fastify/sensible';
import fastifyMetrics from 'fastify-metrics';
import { createHash, randomUUID } from 'crypto';
import pg from 'pg';
import fetch from 'node-fetch';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

dotenv.config();

function autoExternalUrl(service, apiExternalUrl, serviceExternalUrl, serviceInternalUrl, defaultUrl) {
  // ...
  if (process.env.MEDIA_EXTERNAL_URL) return process.env.MEDIA_EXTERNAL_URL;
  if (serviceExternalUrl) return serviceExternalUrl;
  if (apiExternalUrl) {
    try {
      const url = new URL(apiExternalUrl);
      const internalUrlStr = serviceInternalUrl || defaultUrl;
      const internalUrl = new URL(internalUrlStr);
      url.port = internalUrl.port;
      return url.toString();
    } catch (e) {
      return defaultUrl;
    }
  }
  return serviceInternalUrl || defaultUrl;
}

// Config
const defaultConfig = {
  port: process.env.PORT || 8080,
  host: '0.0.0.0',
  databaseUrl: process.env.DATABASE_URL || 'postgresql://pxlcensor:devpassword@localhost:5432/pxlcensor',
  mediaServiceUrl: process.env.MEDIA_SERVICE_URL || 'http://localhost:8081',
  apiExternalUrl: process.env.API_EXTERNAL_URL, // e.g. https://yoursite.com
  mediaSigningSecret: process.env.MEDIA_SIGNING_SECRET || 'dev-secret-change-in-production',
  maxUploadBytes: parseInt(process.env.MAX_UPLOAD_MB || '25') * 1024 * 1024,
  authUserHeaders: (process.env.AUTH_USER_HEADER || 'x-auth-request-email')
    .split(',')
    .map((header) => header.trim().toLowerCase())
    .filter(Boolean),
  authUserFallback: process.env.AUTH_USER_FALLBACK || 'shared'
};
async function buildApp(options = {}) {
  const config = { ...defaultConfig, ...process.env, ...options.config };
  
  // This is the correct place to determine the external URL
  config.mediaExternalUrl = autoExternalUrl(
    'media',
    config.apiExternalUrl,
    config.mediaExternalUrl, // This could be passed in tests
    config.mediaServiceUrl,
    'http://localhost:8081'
  );

  const app = Fastify({
    logger: {
      level: process.env.LOG_LEVEL || 'info'
    },
    genReqId: (request) => {
      return request.headers['x-correlation-id'] || randomUUID();
    },
    bodyLimit: config.maxUploadBytes
  });

  app.log.info(`Using media external URL: ${config.mediaExternalUrl}`);

  const pool = options.dbPool || new pg.Pool({
    connectionString: config.databaseUrl,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000
  });

  // Decorate app with db
  app.decorate('db', pool);
  app.decorate('config', config);

  // CORS Configuration
  const allowedOrigins = (process.env.CORS_ALLOWED_ORIGINS || '')
    .split(',')
    .map(o => o.trim())
    .filter(o => o.length > 0);

  await app.register(cors, {
    credentials: true,
    origin: (origin, cb) => {
      // Allow requests with no origin (like mobile apps or curl requests)
      if (!origin) return cb(null, true);
      
      // Development fallback: Allow all if no origins defined (student friendly default)
      // In production, this env var MUST be set.
      if (allowedOrigins.length === 0 && process.env.NODE_ENV !== 'production') {
        return cb(null, true);
      }

      if (allowedOrigins.includes(origin)) {
        return cb(null, true);
      }

      cb(new Error("Not allowed by CORS"), false);
    }
  });
  await app.register(sensible);
  await app.register(fastifyMetrics, { endpoint: '/metrics', clearRegisterOnInit: true });

  app.addHook('onRequest', (request, reply, done) => {
    reply.header('x-correlation-id', request.id);

    request.log.info({
      correlation_id: request.id,
      method: request.method,
      url: request.url
    }, 'request started');

    done();
  });

  // Helper functions
  function calculateSha256(data) {
    return createHash('sha256').update(data).digest('hex');
  }

  function generatePath(mime) {
    const ext = {
      'image/jpeg': 'jpg',
      'image/png': 'png',
      'image/webp': 'webp'
    }[mime] || 'jpg';
    
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const uuid = randomUUID();
    
    return `${year}/${month}/${uuid}.${ext}`;
  }

  function inferMimeFromFilename(name) {
    if (typeof name !== 'string') return '';
    const extension = name.split('.').pop().toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return '';
    }
  }

  async function getSignedUrl(method, path, expiresIn = 300) {
    // If mocked fetch is provided, use it (for unit tests)
    const fetchFn = options.fetch || fetch;
    
    const response = await fetchFn(`${config.mediaServiceUrl}/sign`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ method, path, expiresIn })
    });
    
    if (typeof response.json !== 'function') {
        // Mock might return data directly
        return response;
    }
    return response.json();
  }

  function getUserId(request) {
    for (const headerName of config.authUserHeaders) {
      const headerValue = request.headers[headerName];
      if (Array.isArray(headerValue) && headerValue.length > 0 && headerValue[0]) {
        return headerValue[0].trim();
      }
      if (typeof headerValue === 'string' && headerValue.trim()) {
        return headerValue.trim();
      }
    }
    return config.authUserFallback;
  }

  // Routes

  // Health check
  app.get('/health', async () => {
    try {
      await app.db.query('SELECT 1');
      return { status: 'ok', service: 'api', database: 'connected' };
    } catch (err) {
      return { status: 'error', service: 'api', database: 'disconnected' };
    }
  });

  // Initialize upload
  app.post('/upload-init', async (request) => {
    let body = request.body || {};
    if (Buffer.isBuffer(body)) {
      try {
        body = JSON.parse(body.toString('utf-8'));
      } catch (err) {
        throw app.httpErrors.badRequest('Invalid JSON payload');
      }
    } else if (typeof body === 'string') {
      try {
        body = JSON.parse(body);
      } catch (err) {
        throw app.httpErrors.badRequest('Invalid JSON payload');
      }
    }
    const { filename, mime, bytes, sha256, processing_options } = body;
    const userId = getUserId(request);
    
    // Validate input
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    const normalizedMime = typeof mime === 'string'
      ? mime.split(';')[0].trim().toLowerCase()
      : inferMimeFromFilename(filename);
    if (!allowedMimes.includes(normalizedMime)) {
      throw app.httpErrors.badRequest('Invalid file type');
    }
    
    if (bytes > config.maxUploadBytes) {
      throw app.httpErrors.badRequest(`File too large. Max size: ${config.maxUploadBytes} bytes`);
    }

    // Validate processing options
    const defaultOptions = { method: 'mosaic', mosaic_size: 20 };
    const options = { ...defaultOptions, ...processing_options };
    
    const allowedMethods = ['blur', 'solid', 'none', 'mosaic'];
    if (!allowedMethods.includes(options.method)) {
      throw app.httpErrors.badRequest('Invalid processing method');
    }
    
    if (!Number.isInteger(options.mosaic_size) || options.mosaic_size < 1 || options.mosaic_size > 120) {
      throw app.httpErrors.badRequest('mosaic_size must be integer between 1-120');
    }
    
    // Check for duplicate
    const existing = await app.db.query(
      'SELECT id, status, processed_path FROM images WHERE sha256 = $1 AND user_id = $2',
      [sha256, userId]
    );
    
    if (existing.rows.length > 0) {
      const image = existing.rows[0];
      return {
        image_id: image.id,
        status: image.status,
        processed_path: image.processed_path,
        duplicate: true
      };
    }
    
    // Generate paths
    const originalPath = `originals/${generatePath(normalizedMime)}`;
    
    // Create image record
    const result = await app.db.query(
      `INSERT INTO images (original_path, sha256, mime, bytes, status, processing_options, user_id)
       VALUES ($1, $2, $3, $4, 'uploaded', $5, $6)
       RETURNING id`,
      [originalPath, sha256, normalizedMime, bytes, JSON.stringify(options), userId]
    );
    
    const imageId = result.rows[0].id;
    
    // Log event
    await app.db.query(
      'INSERT INTO events (image_id, type, data) VALUES ($1, $2, $3)',
      [imageId, 'uploaded', JSON.stringify({ mime, bytes })]
    );
    
    // Get signed upload URL
    const signed = await getSignedUrl('PUT', `/${originalPath}`);
    
    return {
      image_id: imageId,
      upload_url: `${config.mediaExternalUrl}${signed.url}`,
      upload_headers: signed.headers,
      original_path: originalPath
    };
  });

  // Process image
  app.post('/images/:id/process', async (request) => {
    const imageId = request.params.id;
    const { pipeline = 'deface_boxes' } = request.body;
    const userId = getUserId(request);
    
    // Verify image exists and is uploaded
    const imageResult = await app.db.query(
      'SELECT status, sha256, processing_options FROM images WHERE id = $1 AND user_id = $2',
      [imageId, userId]
    );
    
    if (imageResult.rows.length === 0) {
      throw app.httpErrors.notFound('Image not found');
    }
    
    const image = imageResult.rows[0];
    
    if (image.status === 'processing' || image.status === 'queued') {
      throw app.httpErrors.conflict('Already processing');
    }
    
    if (image.status === 'done') {
      throw app.httpErrors.conflict('Already processed');
    }
    
    // Create dedupe key
    const dedupeKey = `${userId}:${image.sha256}:${pipeline}`;
    
    // Check for existing job
    const existingJob = await app.db.query(
      'SELECT id FROM jobs WHERE dedupe_key = $1',
      [dedupeKey]
    );
    
    if (existingJob.rows.length > 0) {
      return { job_id: existingJob.rows[0].id, duplicate: true };
    }
    
    // Create job
    const jobResult = await app.db.query(
      `INSERT INTO jobs (image_id, kind, status, dedupe_key, processing_options)
       VALUES ($1, $2, 'queued', $3, $4)
       RETURNING id`,
      [imageId, pipeline, dedupeKey, JSON.stringify(image.processing_options)]
    );
    
    const jobId = jobResult.rows[0].id;
    
    // Update image status
    await app.db.query(
      "UPDATE images SET status = 'queued' WHERE id = $1",
      [imageId]
    );
    
    // Log event
    await app.db.query(
      'INSERT INTO events (image_id, type, data) VALUES ($1, $2, $3)',
      [imageId, 'queued', JSON.stringify({ job_id: jobId, pipeline })]
    );
    
    // NOTIFY will be triggered automatically by the database trigger
    
    return { job_id: jobId };
  });

  // List images
  app.get('/images', async (request) => {
    const { status, page = 1, pageSize = 20 } = request.query;
    const offset = (page - 1) * pageSize;
    const userId = getUserId(request);
    
    let query = `
      SELECT id, mime, bytes, status, processed_path, created_at, updated_at
      FROM images
    `;
    const params = [userId];
    const countParams = [userId];
    let countQuery = 'SELECT COUNT(*) AS count FROM images WHERE user_id = $1';
    
    query += ' WHERE user_id = $1';
    
    if (status) {
      query += ' AND status = $2';
      params.push(status);
      countQuery += ' AND status = $2';
      countParams.push(status);
    }
    
    query += ' ORDER BY created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
    params.push(pageSize, offset);
    
    const [result, countResult] = await Promise.all([
      app.db.query(query, params),
      app.db.query(countQuery, countParams)
    ]);
    const totalImages = parseInt(countResult.rows[0].count);
    const totalPages = Math.max(1, Math.ceil(totalImages / pageSize));
    
    // Add processed URLs
    const images = result.rows.map(img => ({
      ...img,
      processed_url: img.processed_path ? 
        `${config.mediaExternalUrl}/${img.processed_path}` : null
    }));
    
    return { images, page, pageSize, totalImages, totalPages };
  });

  // Get image details
  app.get('/images/:id', async (request) => {
    const imageId = request.params.id;
    const userId = getUserId(request);
    
    const result = await app.db.query(
      'SELECT * FROM images WHERE id = $1 AND user_id = $2',
      [imageId, userId]
    );
    
    if (result.rows.length === 0) {
      throw app.httpErrors.notFound('Image not found');
    }
    
    const image = result.rows[0];
    
    // Get events
    const events = await app.db.query(
      'SELECT type, data, at FROM events WHERE image_id = $1 ORDER BY at DESC',
      [imageId]
    );
    
    // Generate signed URL for original if needed
    let originalUrl = null;
    let originalHeaders = null;
    if (image.original_path) {
      const signed = await getSignedUrl('GET', `/${image.original_path}`, 60);
      originalUrl = `${config.mediaExternalUrl}${signed.url}`;
      originalHeaders = signed.headers;
    }

    return {
      ...image,
      original_url: originalUrl,
      original_headers: originalHeaders,
      processed_url: image.processed_path ? 
        `${config.mediaExternalUrl}/${image.processed_path}` : null,
      events: events.rows
    };
  });

  // Delete image - complete cleanup
  app.delete('/images/:id', async (request) => {
    const imageId = request.params.id;
    const userId = getUserId(request);
    request.log.info({ imageId }, 'DELETE request received');
    
    // Note: We need a client for transactions
    const client = await app.db.connect();
    try {
      await client.query('BEGIN');
      
      // Get image details for file cleanup
      const imageResult = await client.query(
        'SELECT original_path, processed_path, sha256 FROM images WHERE id = $1 AND user_id = $2',
        [imageId, userId]
      );
      
      if (imageResult.rows.length === 0) {
        request.log.warn({ imageId }, 'Image not found in database');
        throw app.httpErrors.notFound('Image not found');
      }
      
      const image = imageResult.rows[0];
      request.log.info({ imageId, sha256: image.sha256 }, 'Deleting image');
      
      // Delete all related jobs first (to maintain referential integrity)
      const jobsDeleted = await client.query('DELETE FROM jobs WHERE image_id = $1', [imageId]);
      request.log.info({ imageId, count: jobsDeleted.rowCount }, 'Deleted related jobs');
      
      // Delete all events
      const eventsDeleted = await client.query('DELETE FROM events WHERE image_id = $1', [imageId]);
      request.log.info({ imageId, count: eventsDeleted.rowCount }, 'Deleted related events');
      
      // Delete the image record (this will also cascade delete related records)
      const imageDeleted = await client.query('DELETE FROM images WHERE id = $1', [imageId]);
      request.log.info({ imageId, count: imageDeleted.rowCount }, 'Deleted image record');
      
      await client.query('COMMIT');
      request.log.info({ imageId }, 'Database transaction committed');
      
      // Delete files from media service (don't let file deletion failure break the DB transaction)
      const filesToDelete = [];
      if (image.original_path) filesToDelete.push(image.original_path);
      if (image.processed_path) filesToDelete.push(image.processed_path);
      
      // Delete files asynchronously - errors logged but not thrown
      for (const filePath of filesToDelete) {
        try {
          const signed = await getSignedUrl('DELETE', `/${filePath}`);
          
          // Use fetch from options or default
          const fetchFn = options.fetch || fetch;
          const deleteResponse = await fetchFn(`${config.mediaServiceUrl}${signed.url}`, {
            method: 'DELETE',
            headers: signed.headers
          });
          
          if (deleteResponse.ok === false) {
            request.log.warn({ filePath, statusText: deleteResponse.statusText }, 'Failed to delete file');
          }
        } catch (err) {
          request.log.error({ filePath, err: err.message }, 'Error deleting file');
        }
      }
      
      return { success: true, message: 'Image and all related data deleted successfully' };
      
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  });

  // Get job status
  app.get('/jobs/:id', async (request) => {
    const jobId = request.params.id;
    const userId = getUserId(request);
    
    const result = await app.db.query(
      `SELECT j.*
       FROM jobs j
       JOIN images i ON i.id = j.image_id
       WHERE j.id = $1 AND i.user_id = $2`,
      [jobId, userId]
    );
    
    if (result.rows.length === 0) {
      throw app.httpErrors.notFound('Job not found');
    }
    
    return result.rows[0];
  });

  // Queue stats
  app.get('/queue', async (request) => {
    const userId = getUserId(request);
    const stats = await app.db.query(
      `SELECT j.status, COUNT(*) AS count
       FROM jobs j
       JOIN images i ON i.id = j.image_id
       WHERE j.created_at > NOW() - interval '24 hours'
         AND i.user_id = $1
       GROUP BY j.status`,
      [userId]
    );
    
    const total = await app.db.query(
      `SELECT COUNT(*) as count
       FROM jobs j
       JOIN images i ON i.id = j.image_id
       WHERE j.created_at > NOW() - interval '24 hours'
         AND i.user_id = $1`,
      [userId]
    );
    
    return {
      stats: stats.rows,
      total_24h: parseInt(total.rows[0].count)
    };
  });

  // Queue stats across all users
  app.get('/queue/global', async () => {
    const results = await app.db.query(
      `SELECT i.user_id, j.status, COUNT(*)::int AS count
       FROM jobs j
       JOIN images i ON i.id = j.image_id
       WHERE j.created_at > NOW() - interval '24 hours'
       GROUP BY i.user_id, j.status
       ORDER BY i.user_id`
    );

    const users = {};
    results.rows.forEach((row) => {
      if (!users[row.user_id]) {
        users[row.user_id] = {
          user_id: row.user_id,
          queued: 0,
          processing: 0,
          done: 0,
          failed: 0,
          total_24h: 0
        };
      }
      users[row.user_id][row.status] = row.count;
      users[row.user_id].total_24h += row.count;
    });

    return { users: Object.values(users) };
  });

  // System metrics (global)
  app.get('/queue/metrics', async () => {
    const totalImages = await app.db.query('SELECT COUNT(*) AS count FROM images');
    const processedImages = await app.db.query(
      "SELECT COUNT(*) AS count FROM images WHERE status = 'done'"
    );
    const recentFailures = await app.db.query(
      "SELECT COUNT(*) AS count FROM jobs WHERE status = 'failed' AND created_at > NOW() - interval '24 hours'"
    );
    const queuedJobs = await app.db.query(
      "SELECT COUNT(*) AS count FROM jobs WHERE status = 'queued'"
    );

    return {
      total_images: parseInt(totalImages.rows[0].count),
      processed_images: parseInt(processedImages.rows[0].count),
      recent_failures: parseInt(recentFailures.rows[0].count),
      queued_jobs: parseInt(queuedJobs.rows[0].count)
    };
  });
  
  return app;
}

// Start server if run directly
let app;
let pool;

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    app = await buildApp();
    pool = app.db;
    await app.listen({ port: defaultConfig.port, host: defaultConfig.host });
    app.log.info(`API service running on port ${defaultConfig.port}`);
  } catch (err) {
    if (app) app.log.error(err);
    else console.error(err);
    process.exit(1);
  }
} else {
  // For integration tests that import app/pool
  // We need to wait for them to call buildApp if they want to customize it
  // But legacy tests expect 'app' export.
  // We'll export a default built app if not running directly
  app = await buildApp();
  pool = app.db;
}

export { app, pool, buildApp };
