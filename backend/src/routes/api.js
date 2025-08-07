const { getPgPool, getRedisClient } = require('../database/connection');

const apiRoutes = async (fastify, options) => {
  fastify.get('/stats', async (request, reply) => {
    try {
      const pool = getPgPool();
      const redis = getRedisClient();

      const [userCount, sessionCount, messageCount] = await Promise.all([
        pool.query('SELECT COUNT(*) as count FROM users WHERE is_online = true'),
        pool.query('SELECT COUNT(*) as count FROM chat_sessions WHERE is_active = true'),
        pool.query('SELECT COUNT(*) as count FROM messages WHERE created_at > NOW() - INTERVAL \'24 hours\'')
      ]);

      const queueStats = {};
      const interests = ['science', 'tech', 'politics', 'personal'];
      
      for (const interest of interests) {
        const count = await redis.llen(`queue:${interest}`);
        queueStats[interest] = count;
      }

      return {
        users: {
          online: parseInt(userCount.rows[0].count),
          total: parseInt(userCount.rows[0].count)
        },
        sessions: {
          active: parseInt(sessionCount.rows[0].count)
        },
        messages: {
          last24h: parseInt(messageCount.rows[0].count)
        },
        queue: queueStats,
        matches: {
          total: 0,
          ...queueStats
        },
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Stats error:', error);
      reply.status(500);
      return { error: 'Failed to get stats' };
    }
  });

  fastify.get('/queue', async (request, reply) => {
    try {
      const redis = getRedisClient();
      const interests = ['science', 'tech', 'politics', 'personal'];
      const queueStats = {};

      for (const interest of interests) {
        const count = await redis.llen(`queue:${interest}`);
        queueStats[interest] = count;
      }

      return {
        queue: queueStats,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Queue stats error:', error);
      reply.status(500);
      return { error: 'Failed to get queue stats' };
    }
  });

  fastify.get('/interests', async (request, reply) => {
    try {
      const pool = getPgPool();
      const result = await pool.query('SELECT name, active_users, total_sessions FROM interests ORDER BY active_users DESC');
      
      return {
        interests: result.rows,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Interests error:', error);
      reply.status(500);
      return { error: 'Failed to get interests' };
    }
  });

  fastify.get('/activity', async (request, reply) => {
    try {
      const pool = getPgPool();
      const result = await pool.query(`
        SELECT action, COUNT(*) as count 
        FROM user_activity 
        WHERE created_at > NOW() - INTERVAL '24 hours'
        GROUP BY action 
        ORDER BY count DESC
      `);

      return {
        activity: result.rows,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Activity error:', error);
      reply.status(500);
      return { error: 'Failed to get activity' };
    }
  });

  fastify.get('/system', async (request, reply) => {
    try {
      const pool = getPgPool();
      const redis = getRedisClient();

      const [dbSize, redisInfo] = await Promise.all([
        pool.query('SELECT pg_database_size(current_database()) as size'),
        redis.info('memory')
      ]);

      const memoryUsage = process.memoryUsage();
      const uptime = process.uptime();

      return {
        system: {
          uptime,
          memory: {
            rss: memoryUsage.rss,
            heapUsed: memoryUsage.heapUsed,
            heapTotal: memoryUsage.heapTotal,
            external: memoryUsage.external
          },
          database: {
            size: parseInt(dbSize.rows[0].size)
          },
          redis: {
            connected: redis.isReady
          }
        },
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('System info error:', error);
      reply.status(500);
      return { error: 'Failed to get system info' };
    }
  });
};

module.exports = apiRoutes; 