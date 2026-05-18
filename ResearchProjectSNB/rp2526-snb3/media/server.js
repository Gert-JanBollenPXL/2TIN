import Fastify from 'fastify';
import fastifyStatic from '@fastify/static';
import cors from '@fastify/cors';
import sensible from '@fastify/sensible';
import { createHmac } from 'crypto';
import { promises as fs } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const app = Fastify({
  logger: {
    level: process.env.LOG_LEVEL || 'info'
  },
  bodyLimit: 26 * 1024 * 1024 // 26MB to handle 25MB files plus overhead
});

// Config
const config = {
  port: process.env.PORT || 8081,
  host: '0.0.0.0',
  mediaRoot: process.env.MEDIA_ROOT || path.join(__dirname, '../media-data'),
  signingSecret: process.env.MEDIA_SIGNING_SECRET || 'dev-secret-change-in-production'
};

// Register plugins
const allowedOrigins = (process.env.CORS_ALLOWED_ORIGINS || '')
  .split(',')
  .map(o => o.trim())
  .filter(o => o.length > 0);

await app.register(cors, {
  credentials: true,
  origin: (origin, cb) => {
    if (!origin) return cb(null, true);
    if (allowedOrigins.length === 0 && process.env.NODE_ENV !== 'production') return cb(null, true);
    if (allowedOrigins.includes(origin)) return cb(null, true);
    cb(new Error("Not allowed by CORS"), false);
  }
});
await app.register(sensible);

// Add content type parser for binary uploads
app.addContentTypeParser(['image/jpeg', 'image/png', 'image/webp', 'application/octet-stream'], 
  { parseAs: 'buffer' }, 
  async (req, body) => body
);

// Serve static files from processed directory
await app.register(fastifyStatic, {
  root: path.join(config.mediaRoot, 'processed'),
  prefix: '/processed/',
  serve: true,
  list: false
});

// HMAC verification hook for signed routes
async function verifyHmac(request, reply) {
  const signature = request.headers['x-signature'];
  const expires = parseInt(request.headers['x-expires']);
  
  if (!signature || !expires) {
    return reply.code(401).send({ error: 'Missing signature' });
  }

  if (Date.now() > expires) {
    return reply.code(403).send({ error: 'Signature expired' });
  }

  const method = request.method;
  const path = request.url.split('?')[0];
  const expected = createHmac('sha256', config.signingSecret)
    .update(`${method}:${path}:${expires}`)
    .digest('hex');

  if (signature !== expected) {
    return reply.code(403).send({ error: 'Invalid signature' });
  }
}

// Ensure directory exists
async function ensureDir(dirPath) {
  await fs.mkdir(dirPath, { recursive: true });
}

// Routes
app.get('/health', async () => ({ status: 'ok', service: 'media' }));

// Signed URL generation endpoint (internal use)
app.post('/sign', async (request) => {
  const { method, path, expiresIn = 300 } = request.body;
  const expires = Date.now() + (expiresIn * 1000);
  
  const signature = createHmac('sha256', config.signingSecret)
    .update(`${method}:${path}:${expires}`)
    .digest('hex');
  
  return { 
    url: `${path}`,
    headers: {
      'X-Signature': signature,
      'X-Expires': expires
    }
  };
});

// Upload endpoint with HMAC verification
app.put('/originals/*', { preHandler: verifyHmac }, async (request) => {
  const filepath = request.params['*'];
  const fullPath = path.join(config.mediaRoot, 'originals', filepath);
  
  await ensureDir(path.dirname(fullPath));
  
  // Write atomically
  const tempPath = `${fullPath}.tmp`;
  await fs.writeFile(tempPath, request.body);
  await fs.rename(tempPath, fullPath);
  
  return { success: true, path: `originals/${filepath}` };
});

app.put('/processed/*', { preHandler: verifyHmac }, async (request) => {
  const filepath = request.params['*'];
  const fullPath = path.join(config.mediaRoot, 'processed', filepath);
  
  await ensureDir(path.dirname(fullPath));
  
  const tempPath = `${fullPath}.tmp`;
  await fs.writeFile(tempPath, request.body);
  await fs.rename(tempPath, fullPath);
  
  return { success: true, path: `processed/${filepath}` };
});

// Get original with signature
app.get('/originals/*', { preHandler: verifyHmac }, async (request, reply) => {
  const filepath = request.params['*'];
  const fullPath = path.join(config.mediaRoot, 'originals', filepath);
  
  try {
    const file = await fs.readFile(fullPath);
    const ext = path.extname(filepath);
    const contentType = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg', 
      '.png': 'image/png',
      '.webp': 'image/webp'
    }[ext] || 'application/octet-stream';
    
    return reply.type(contentType).send(file);
  } catch (err) {
    if (err.code === 'ENOENT') {
      return reply.notFound();
    }
    throw err;
  }
});

// Delete original with signature
app.delete('/originals/*', { preHandler: verifyHmac }, async (request, reply) => {
  const filepath = request.params['*'];
  const fullPath = path.join(config.mediaRoot, 'originals', filepath);
  
  try {
    await fs.unlink(fullPath);
    return { success: true, message: `Deleted originals/${filepath}` };
  } catch (err) {
    if (err.code === 'ENOENT') {
      return reply.notFound({ error: `File not found: originals/${filepath}` });
    }
    throw err;
  }
});

// Delete processed with signature
app.delete('/processed/*', { preHandler: verifyHmac }, async (request, reply) => {
  const filepath = request.params['*'];
  const fullPath = path.join(config.mediaRoot, 'processed', filepath);
  
  try {
    await fs.unlink(fullPath);
    return { success: true, message: `Deleted processed/${filepath}` };
  } catch (err) {
    if (err.code === 'ENOENT') {
      return reply.notFound({ error: `File not found: processed/${filepath}` });
    }
    throw err;
  }
});

// Start server
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    await app.listen({ port: config.port, host: config.host });
    app.log.info(`Media service running on port ${config.port}`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
}

export { app };
