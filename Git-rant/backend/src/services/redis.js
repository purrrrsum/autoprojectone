// backend/src/services/redis.js
const Redis = require('redis');

let redisClient;

async function initializeRedis() {
  if (!redisClient) {
    redisClient = Redis.createClient({
      url: process.env.REDIS_URL,
      socket: {
        reconnectStrategy: (retries) => Math.min(retries * 50, 2000),
      },
    });

    redisClient.on('error', (err) => {
      console.error('Redis Client Error:', err);
    });

    await redisClient.connect();
    console.log('Connected to Redis');
  }
  return redisClient;
}

module.exports = { initializeRedis }; 