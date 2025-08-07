const { Pool } = require('pg');
const { createClient } = require('redis');
const fs = require('fs').promises;
const path = require('path');

let pgPool = null;
let redisClient = null;

async function setupDatabase() {
  try {
    pgPool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    });

    const client = await pgPool.connect();
    await client.query('SELECT NOW()');
    client.release();
    console.log('PostgreSQL connected');

    redisClient = createClient({
      url: process.env.REDIS_URL,
      socket: {
        reconnectStrategy: (retries) => Math.min(retries * 50, 500)
      }
    });

    redisClient.on('error', (err) => console.error('Redis Client Error:', err));
    redisClient.on('connect', () => console.log('Redis connected'));

    await redisClient.connect();
    await runMigrations();

  } catch (error) {
    console.error('Database setup failed:', error);
    throw error;
  }
}

async function runMigrations() {
  try {
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schema = await fs.readFile(schemaPath, 'utf8');
    
    const client = await pgPool.connect();
    await client.query(schema);
    client.release();
    
    console.log('Database migrations completed');
  } catch (error) {
    console.error('Migration failed:', error);
    throw error;
  }
}

function getPgPool() {
  if (!pgPool) {
    throw new Error('Database not initialized');
  }
  return pgPool;
}

function getRedisClient() {
  if (!redisClient) {
    throw new Error('Redis not initialized');
  }
  return redisClient;
}

async function closeConnections() {
  if (pgPool) {
    await pgPool.end();
  }
  if (redisClient) {
    await redisClient.quit();
  }
}

module.exports = {
  setupDatabase,
  getPgPool,
  getRedisClient,
  closeConnections
}; 