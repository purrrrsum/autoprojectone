const jwt = require('jsonwebtoken');
const { getRedisClient } = require('../database/connection');

async function authMiddleware(request, reply) {
  const publicRoutes = ['/health', '/api/health', '/api/stats'];
  if (publicRoutes.includes(request.url)) {
    return;
  }

  const token = request.headers.authorization?.replace('Bearer ', '');
  
  if (!token) {
    return reply.status(401).send({
      error: 'Unauthorized',
      message: 'No token provided'
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    request.user = decoded;
  } catch (error) {
    return reply.status(401).send({
      error: 'Unauthorized',
      message: 'Invalid token'
    });
  }
}

async function rateLimitMiddleware(request, reply) {
  const redis = getRedisClient();
  const key = `rate_limit:${request.ip}`;
  
  try {
    const current = await redis.incr(key);
    
    if (current === 1) {
      await redis.expire(key, 60);
    }
    
    if (current > 100) {
      return reply.status(429).send({
        error: 'Too Many Requests',
        message: 'Rate limit exceeded'
      });
    }
  } catch (error) {
    console.error('Rate limiting error:', error);
  }
}

function corsMiddleware(request, reply) {
  const origin = request.headers.origin;
  const allowedOrigins = process.env.NODE_ENV === 'production'
    ? ['https://rant.zone', 'https://www.rant.zone']
    : ['http://localhost:3000', 'http://localhost:3001'];

  if (origin && allowedOrigins.includes(origin)) {
    reply.header('Access-Control-Allow-Origin', origin);
  }

  reply.header('Access-Control-Allow-Credentials', 'true');
  reply.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  reply.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
}

function securityMiddleware(request, reply) {
  reply.header('X-Content-Type-Options', 'nosniff');
  reply.header('X-Frame-Options', 'DENY');
  reply.header('X-XSS-Protection', '1; mode=block');
  reply.header('Referrer-Policy', 'strict-origin-when-cross-origin');
  reply.header('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
  reply.header('Server', 'RantZone');
  
  const csp = [
    "default-src 'self'",
    "script-src 'self' 'unsafe-inline'",
    "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
    "font-src 'self' https://fonts.gstatic.com",
    "img-src 'self' data: https:",
    "connect-src 'self' wss: ws:",
    "object-src 'none'",
    "media-src 'none'",
    "frame-src 'none'"
  ].join('; ');
  
  reply.header('Content-Security-Policy', csp);
}

module.exports = {
  authMiddleware,
  rateLimitMiddleware,
  corsMiddleware,
  securityMiddleware
}; 
