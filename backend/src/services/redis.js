const Redis = require('redis');

let redisClient;

async function initializeRedis() {
  if (!redisClient) {
    redisClient = Redis.createClient({ url: process.env.REDIS_URL });
    redisClient.on('error', (err) => console.error('Redis Error:', err));
    await redisClient.connect();
    console.log('Connected to Redis');
  }
  return redisClient;
}

module.exports = { initializeRedis }; 