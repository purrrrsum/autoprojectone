const { v4: uuidv4 } = require('uuid');
const { getPgPool, getRedisClient } = require('../database/connection');
const { moderateContent } = require('../utils/moderation');
const { encryptMessage, decryptMessage } = require('../utils/encryption');

class WebSocketService {
  constructor() {
    this.clients = new Map();
    this.userSessions = new Map();
    this.chatSessions = new Map();
  }

  setup(wss) {
    wss.on('connection', (ws, req) => {
      this.handleConnection(ws, req);
    });

    setInterval(() => {
      this.cleanupExpiredMessages();
    }, 60 * 60 * 1000);
  }

  async handleConnection(ws, req) {
    const sessionId = uuidv4();
    const clientInfo = {
      ws,
      sessionId,
      userId: null,
      interest: null,
      connectedAt: Date.now(),
      isAuthenticated: false
    };

    this.clients.set(sessionId, clientInfo);

    console.log(`WebSocket connected: ${sessionId}`);

    ws.on('message', async (data) => {
      try {
        const message = JSON.parse(data);
        await this.handleMessage(sessionId, message);
      } catch (error) {
        console.error('Message handling error:', error);
        this.sendError(sessionId, 'Invalid message format');
      }
    });

    ws.on('close', () => {
      this.handleDisconnection(sessionId);
    });

    ws.on('error', (error) => {
      console.error('WebSocket error:', error);
      this.handleDisconnection(sessionId);
    });

    this.sendMessage(sessionId, {
      type: 'connected',
      sessionId,
      timestamp: Date.now()
    });
  }

  async handleMessage(sessionId, message) {
    const client = this.clients.get(sessionId);
    if (!client) return;

    switch (message.type) {
      case 'join':
        await this.handleJoin(sessionId, message.payload);
        break;
      case 'message':
        await this.handleChatMessage(sessionId, message.payload);
        break;
      case 'leave':
        await this.handleLeave(sessionId);
        break;
      case 'typing':
        await this.handleTyping(sessionId, message.payload);
        break;
      default:
        this.sendError(sessionId, 'Unknown message type');
    }
  }

  async handleJoin(sessionId, payload) {
    const { interest } = payload;
    const client = this.clients.get(sessionId);
    
    if (!interest || !['science', 'tech', 'politics', 'personal'].includes(interest)) {
      this.sendError(sessionId, 'Invalid interest');
      return;
    }

    try {
      const userId = await this.createUser(sessionId, interest);
      
      client.userId = userId;
      client.interest = interest;
      client.isAuthenticated = true;
      
      this.userSessions.set(userId, sessionId);
      
      await this.addToMatchingQueue(userId, interest);
      
      this.sendMessage(sessionId, {
        type: 'joined',
        userId,
        interest,
        timestamp: Date.now()
      });

      console.log(`User ${userId} joined ${interest} chat`);
    } catch (error) {
      console.error('Join error:', error);
      this.sendError(sessionId, 'Failed to join chat');
    }
  }

  async handleChatMessage(sessionId, payload) {
    const client = this.clients.get(sessionId);
    if (!client || !client.isAuthenticated) {
      this.sendError(sessionId, 'Not authenticated');
      return;
    }

    const { content, chatSessionId, iv, tag } = payload;
    
    if (!content || !chatSessionId) {
      this.sendError(sessionId, 'Invalid message format');
      return;
    }

    try {
      const moderationResult = moderateContent(content);
      if (!moderationResult.isAllowed) {
        this.sendError(sessionId, `Message blocked: ${moderationResult.reason}`);
        return;
      }

      const messageId = uuidv4();
      const encryptedContent = await encryptMessage(content);
      
      await this.storeMessage(chatSessionId, client.userId, content, encryptedContent);
      
      this.sendMessage(sessionId, {
        type: 'message_sent',
        messageId,
        timestamp: Date.now()
      });

      await this.sendToPartner(chatSessionId, client.userId, {
        type: 'message',
        messageId,
        content: encryptedContent,
        iv,
        tag,
        timestamp: Date.now()
      });

    } catch (error) {
      console.error('Message handling error:', error);
      this.sendError(sessionId, 'Failed to send message');
    }
  }

  async handleLeave(sessionId) {
    await this.handleDisconnection(sessionId);
  }

  async handleTyping(sessionId, payload) {
    const client = this.clients.get(sessionId);
    if (!client || !client.isAuthenticated) return;

    const { isTyping, chatSessionId } = payload;
    
    await this.sendToPartner(chatSessionId, client.userId, {
      type: 'typing',
      isTyping,
      timestamp: Date.now()
    });
  }

  async handleDisconnection(sessionId) {
    const client = this.clients.get(sessionId);
    if (!client) return;

    if (client.userId) {
      await this.updateUserStatus(client.userId, false);
      await this.removeFromMatchingQueue(client.userId);
      await this.notifyPartnerDisconnect(client.userId);
      this.userSessions.delete(client.userId);
    }

    this.clients.delete(sessionId);
    console.log(`WebSocket disconnected: ${sessionId}`);
  }

  async createUser(sessionId, interest) {
    const pool = getPgPool();
    const result = await pool.query(
      'INSERT INTO users (session_id, interest, is_online) VALUES ($1, $2, $3) RETURNING id',
      [sessionId, interest, true]
    );
    return result.rows[0].id;
  }

  async updateUserStatus(userId, isOnline) {
    const pool = getPgPool();
    await pool.query(
      'UPDATE users SET is_online = $1, last_seen = NOW() WHERE id = $2',
      [isOnline, userId]
    );
  }

  async addToMatchingQueue(userId, interest) {
    const redis = getRedisClient();
    await redis.lpush(`queue:${interest}`, userId);
  }

  async removeFromMatchingQueue(userId) {
    const redis = getRedisClient();
    const interests = ['science', 'tech', 'politics', 'personal'];
    
    for (const interest of interests) {
      await redis.lrem(`queue:${interest}`, 0, userId);
    }
  }

  async storeMessage(chatSessionId, senderId, content, encryptedContent) {
    const pool = getPgPool();
    const contentHash = this.hashContent(content);
    
    await pool.query(
      'INSERT INTO messages (chat_session_id, sender_id, encrypted_content, content_hash) VALUES ($1, $2, $3, $4)',
      [chatSessionId, senderId, encryptedContent, contentHash]
    );
  }

  hashContent(content) {
    const crypto = require('crypto');
    return crypto.createHash('sha256').update(content).digest('hex');
  }

  async sendToPartner(chatSessionId, senderId, message) {
    const pool = getPgPool();
    const result = await pool.query(
      'SELECT user1_id, user2_id FROM chat_sessions WHERE id = $1',
      [chatSessionId]
    );

    if (result.rows.length === 0) return;

    const session = result.rows[0];
    const partnerId = session.user1_id === senderId ? session.user2_id : session.user1_id;
    const partnerSessionId = this.userSessions.get(partnerId);

    if (partnerSessionId) {
      this.sendMessage(partnerSessionId, message);
    }
  }

  async notifyPartnerDisconnect(userId) {
    const pool = getPgPool();
    const result = await pool.query(
      'SELECT user1_id, user2_id FROM chat_sessions WHERE (user1_id = $1 OR user2_id = $1) AND is_active = true',
      [userId]
    );

    for (const session of result.rows) {
      const partnerId = session.user1_id === userId ? session.user2_id : session.user1_id;
      const partnerSessionId = this.userSessions.get(partnerId);

      if (partnerSessionId) {
        this.sendMessage(partnerSessionId, {
          type: 'partner_disconnected',
          timestamp: Date.now()
        });
      }
    }
  }

  async cleanupExpiredMessages() {
    const pool = getPgPool();
    const result = await pool.query('SELECT cleanup_expired_messages()');
    console.log(`Cleaned up ${result.rows[0].cleanup_expired_messages} expired messages`);
  }

  sendMessage(sessionId, message) {
    const client = this.clients.get(sessionId);
    if (client && client.ws.readyState === 1) {
      client.ws.send(JSON.stringify(message));
    }
  }

  sendError(sessionId, error) {
    this.sendMessage(sessionId, {
      type: 'error',
      error,
      timestamp: Date.now()
    });
  }

  async matchUsers(interest) {
    const redis = getRedisClient();
    const queueKey = `queue:${interest}`;
    
    const user1 = await redis.rpop(queueKey);
    const user2 = await redis.rpop(queueKey);
    
    if (user1 && user2) {
      await this.createChatSession(user1, user2, interest);
      return { user1, user2, interest };
    }
    
    return null;
  }

  async createChatSession(user1Id, user2Id, interest) {
    const pool = getPgPool();
    const result = await pool.query(
      'INSERT INTO chat_sessions (user1_id, user2_id, interest) VALUES ($1, $2, $3) RETURNING id',
      [user1Id, user2Id, interest]
    );

    const sessionId = result.rows[0].id;
    this.chatSessions.set(sessionId, { user1Id, user2Id, messages: [] });

    const user1SessionId = this.userSessions.get(user1Id);
    const user2SessionId = this.userSessions.get(user2Id);

    if (user1SessionId) {
      this.sendMessage(user1SessionId, {
        type: 'matched',
        chatSessionId: sessionId,
        interest,
        timestamp: Date.now()
      });
    }

    if (user2SessionId) {
      this.sendMessage(user2SessionId, {
        type: 'matched',
        chatSessionId: sessionId,
        interest,
        timestamp: Date.now()
      });
    }

    console.log(`Matched users: ${user1Id} + ${user2Id} (${interest})`);
  }
}

const webSocketService = new WebSocketService();

function setupWebSocket(wss) {
  webSocketService.setup(wss);
}

module.exports = {
  setupWebSocket,
  webSocketService
}; 