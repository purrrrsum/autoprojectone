// backend/src/services/matching.js
const { initializeRedis } = require('./redis');
const { pool } = require('../database/connection');

const waitingUsers = new Map(); // In-memory queue for simplicity, can be moved to Redis

async function startMatchingEngine() {
  const redis = await initializeRedis();

  redis.subscribe('matching:channel', async (message) => {
    const { userId, interest, gender } = JSON.parse(message);

    // Add to waiting queue
    if (!waitingUsers.has(interest)) {
      waitingUsers.set(interest, []);
    }
    waitingUsers.get(interest).push({ userId, gender });

    // Try to match
    const queue = waitingUsers.get(interest);
    if (queue.length >= 2) {
      const user1 = queue.shift();
      const user2 = queue.shift();

      // Optional gender filter: Skip if same gender (example logic)
      if (gender && user1.gender === user2.gender) {
        queue.push(user1); // Put back
        return;
      }

      // Create session
      const sessionId = `session-${Date.now()}`;
      await pool.query(
        'INSERT INTO chat_sessions (session_id, interest, user1_id, user2_id, status) VALUES ($1, $2, $3, $4, $5)',
        [sessionId, interest, user1.userId, user2.userId, 'active']
      );

      // Publish match event
      await redis.publish('matched:channel', JSON.stringify({
        type: 'matched',
        sessionId,
        users: [user1.userId, user2.userId]
      }));
    }
  });

  console.log('Matching engine started');
}

module.exports = { startMatchingEngine }; 