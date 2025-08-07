const { initializeRedis } = require('./redis');
const { pool } = require('../database/connection');

async function startMatchingEngine() {
  const redis = await initializeRedis();
  // Matching logic here
  console.log('Matching engine started');
}

module.exports = { startMatchingEngine }; 