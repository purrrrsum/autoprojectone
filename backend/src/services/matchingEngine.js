const { getRedisClient } = require('../database/connection');

class MatchingEngine {
  constructor() {
    this.interests = ['science', 'tech', 'politics', 'personal'];
    this.matchingInterval = null;
  }

  start() {
    this.matchingInterval = setInterval(() => {
      this.processMatching();
    }, 5000);
    console.log('Matching engine started');
  }

  stop() {
    if (this.matchingInterval) {
      clearInterval(this.matchingInterval);
      this.matchingInterval = null;
    }
    console.log('Matching engine stopped');
  }

  async processMatching() {
    try {
      for (const interest of this.interests) {
        await this.matchUsersForInterest(interest);
      }
    } catch (error) {
      console.error('Matching error:', error);
    }
  }

  async matchUsersForInterest(interest) {
    const redis = getRedisClient();
    const queueKey = `queue:${interest}`;
    
    try {
      const queueLength = await redis.lLen(queueKey);
      
      if (queueLength >= 2) {
        const user1 = await redis.rPop(queueKey);
        const user2 = await redis.rPop(queueKey);
        
        if (user1 && user2) {
          await this.createChatSession(user1, user2, interest);
        }
      }
    } catch (error) {
      console.error(`Matching error for ${interest}:`, error);
    }
  }

  async createChatSession(user1Id, user2Id, interest) {
    try {
      const pool = require('../database/connection').getPgPool();
      
      const result = await pool.query(
        'INSERT INTO chat_sessions (user1_id, user2_id, interest) VALUES ($1, $2, $3) RETURNING id',
        [user1Id, user2Id, interest]
      );

      const sessionId = result.rows[0].id;
      
      await this.notifyUsers(sessionId, user1Id, user2Id, interest);
      
      console.log(`Created chat session ${sessionId} for users ${user1Id} and ${user2Id} (${interest})`);
      
      return sessionId;
    } catch (error) {
      console.error('Chat session creation error:', error);
      throw error;
    }
  }

  async notifyUsers(sessionId, user1Id, user2Id, interest) {
    const { webSocketService } = require('./websocket');
    
    const user1SessionId = webSocketService.userSessions.get(user1Id);
    const user2SessionId = webSocketService.userSessions.get(user2Id);

    if (user1SessionId) {
      webSocketService.sendMessage(user1SessionId, {
        type: 'matched',
        chatSessionId: sessionId,
        interest,
        timestamp: Date.now()
      });
    }

    if (user2SessionId) {
      webSocketService.sendMessage(user2SessionId, {
        type: 'matched',
        chatSessionId: sessionId,
        interest,
        timestamp: Date.now()
      });
    }
  }

  async getQueueStats() {
    const redis = getRedisClient();
    const stats = {};
    
    for (const interest of this.interests) {
      const count = await redis.lLen(`queue:${interest}`);
      stats[interest] = count;
    }
    
    return stats;
  }

  async getMatchStatistics() {
    try {
      const pool = require('../database/connection').getPgPool();
      
      const result = await pool.query(`
        SELECT 
          interest,
          COUNT(*) as total_matches,
          COUNT(CASE WHEN created_at > NOW() - INTERVAL '24 hours' THEN 1 END) as matches_24h
        FROM chat_sessions 
        GROUP BY interest
      `);
      
      const stats = {
        total: 0,
        science: 0,
        tech: 0,
        politics: 0,
        personal: 0
      };
      
      result.rows.forEach(row => {
        stats[row.interest] = parseInt(row.total_matches);
        stats.total += parseInt(row.total_matches);
      });
      
      return stats;
    } catch (error) {
      console.error('Match statistics error:', error);
      return { total: 0, science: 0, tech: 0, politics: 0, personal: 0 };
    }
  }
}

const matchingEngine = new MatchingEngine();

function setupMatchingEngine() {
  matchingEngine.start();
}

module.exports = {
  setupMatchingEngine,
  matchingEngine
}; 
