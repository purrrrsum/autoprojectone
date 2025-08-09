const { authMiddleware, rateLimitMiddleware, corsMiddleware, securityMiddleware } = require('./auth');

async function setupMiddleware(app) {
  await app.register(require('@fastify/cors'), {
    origin: process.env.NODE_ENV === 'production'
      ? ['https://rant.zone', 'https://www.rant.zone']
      : ['http://localhost:3000', 'http://localhost:3001'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
  });

  await app.register(require('@fastify/rate-limit'), {
    max: 100,
    timeWindow: '1 minute',
    allowList: ['127.0.0.1', 'localhost'],
    keyGenerator: (request) => {
      return request.ip || request.headers['x-forwarded-for'] || 'unknown';
    }
  });

  await app.register(require('@fastify/helmet'), {
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", "data:", "https:"],
        connectSrc: ["'self'", "wss:", "ws:"],
        fontSrc: ["'self'", "https://fonts.gstatic.com"],
        objectSrc: ["'none'"],
        mediaSrc: ["'none'"],
        frameSrc: ["'none'"]
      }
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true
    }
  });

  app.addHook('preHandler', authMiddleware);
  app.addHook('preHandler', rateLimitMiddleware);
  app.addHook('preHandler', corsMiddleware);
  app.addHook('preHandler', securityMiddleware);

  app.setErrorHandler((error, request, reply) => {
    console.error('Request error:', error);

    if (error.validation) {
      return reply.status(400).send({
        error: 'Validation Error',
        message: error.message,
        details: error.validation
      });
    }

    if (error.statusCode) {
      return reply.status(error.statusCode).send({
        error: error.name || 'Error',
        message: error.message
      });
    }

    reply.status(500).send({
      error: 'Internal Server Error',
      message: process.env.NODE_ENV === 'production'
        ? 'Something went wrong'
        : error.message
    });
  });
}

module.exports = { setupMiddleware };
