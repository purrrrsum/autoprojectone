const fastify = require('fastify');
const WebSocket = require('ws');
const { setupDatabase } = require('./database/connection');
const { setupMiddleware } = require('./middleware');
const { setupRoutes } = require('./routes');
const { setupWebSocket } = require('./services/websocket');
const { setupMatchingEngine } = require('./services/matchingEngine');
const { initializeRedis } = require('./services/redis');
const { startMatchingEngine } = require('./services/matching');

const PORT = process.env.PORT || 3001;
const HOST = process.env.HOST || '0.0.0.0';

async function startServer() {
  try {
    const app = fastify({
      logger: {
        level: process.env.NODE_ENV === 'production' ? 'warn' : 'info',
        prettyPrint: process.env.NODE_ENV !== 'production'
      },
      trustProxy: true
    });

    await setupDatabase();
    await setupMiddleware(app);
    await setupRoutes(app);

    await app.listen({ port: PORT, host: HOST });
    console.log(`Server running on http://${HOST}:${PORT}`);

    const wss = new WebSocket.Server({ server: app.server });
    setupWebSocket(wss);
    setupMatchingEngine();
    await startMatchingEngine();

    console.log('Chat application backend initialized successfully');

    wss.on('connection', async (ws, request) => {
      console.log('WebSocket client connected');

      const redis = await initializeRedis();

      ws.on('message', async (message) => {
        try {
          const data = JSON.parse(message);

          if (data.type === 'join') {
            // Example: Publish join request to Redis channel for matching
            await redis.publish('matching:channel', JSON.stringify({
              userId: data.userId,
              interest: data.interest,
              gender: data.gender
            }));
            ws.send(JSON.stringify({ type: 'joined', message: 'Waiting for match' }));
          } else if (data.type === 'message') {
            // Example: Publish message to session channel
            await redis.publish(`session:${data.sessionId}`, JSON.stringify(data));
          }

          // Echo back for testing
          ws.send(JSON.stringify({
            type: 'echo',
            data: data
          }));
        } catch (error) {
          console.error('WebSocket message error:', error);
        }
      });

      // Subscribe to personal channel for matched events (example)
      const subscriber = redis.duplicate();
      await subscriber.connect();
      await subscriber.subscribe('matched:channel', (msg) => {
        ws.send(msg);
      });

      ws.on('close', async () => {
        console.log('WebSocket client disconnected');
        await subscriber.disconnect();
      });
    });

  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

process.on('SIGTERM', async () => {
  console.log('Received SIGTERM, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('Received SIGINT, shutting down gracefully');
  process.exit(0);
});

startServer(); 