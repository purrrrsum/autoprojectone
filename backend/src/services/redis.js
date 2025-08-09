const Redis = require('redis');

let redisClient;

async function initializeRedis() {
  if (!redisClient) {
    try {
      redisClient = Redis.createClient({ url: process.env.REDIS_URL });
      redisClient.on('error', (err) => console.error('Redis Error:', err));
      await redisClient.connect();
      console.log('Connected to Redis');
    } catch (error) {
      console.warn('Redis connection failed, running without Redis:', error.message);
      redisClient = null;
    }
  }
  return redisClient;
}

function getRedisClient() {
  return redisClient;
}

module.exports = { initializeRedis, getRedisClient, redisClient };
