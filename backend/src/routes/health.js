const { getPgPool, getRedisClient } = require('../database/connection');

const healthRoutes = async (fastify, options) => {
  fastify.get('/basic', async (request, reply) => {
    return { status: 'ok', timestamp: new Date().toISOString() };
  });

  fastify.get('/database', async (request, reply) => {
    try {
      const pool = getPgPool();
      await pool.query('SELECT NOW()');
      return { status: 'ok', database: 'connected' };
    } catch (error) {
      reply.status(503);
      return { status: 'error', database: 'disconnected', error: error.message };
    }
  });

  fastify.get('/redis', async (request, reply) => {
    try {
      const redis = getRedisClient();
      await redis.ping();
      return { status: 'ok', redis: 'connected' };
    } catch (error) {
      reply.status(503);
      return { status: 'error', redis: 'disconnected', error: error.message };
    }
  });

  fastify.get('/full', async (request, reply) => {
    const checks = {
      server: 'ok',
      database: 'unknown',
      redis: 'unknown'
    };

    try {
      const pool = getPgPool();
      await pool.query('SELECT NOW()');
      checks.database = 'ok';
    } catch (error) {
      checks.database = 'error';
    }

    try {
      const redis = getRedisClient();
      await redis.ping();
      checks.redis = 'ok';
    } catch (error) {
      checks.redis = 'error';
    }

    const allOk = Object.values(checks).every(status => status === 'ok');
    const statusCode = allOk ? 200 : 503;

    reply.status(statusCode);
    return {
      status: allOk ? 'ok' : 'error',
      checks,
      timestamp: new Date().toISOString()
    };
  });

  fastify.get('/ready', async (request, reply) => {
    try {
      const pool = getPgPool();
      await pool.query('SELECT NOW()');
      
      const redis = getRedisClient();
      await redis.ping();
      
      return { status: 'ready', timestamp: new Date().toISOString() };
    } catch (error) {
      reply.status(503);
      return { status: 'not ready', error: error.message };
    }
  });

  fastify.get('/live', async (request, reply) => {
    return { status: 'alive', timestamp: new Date().toISOString() };
  });
};

module.exports = healthRoutes; 