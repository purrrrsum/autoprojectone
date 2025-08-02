const fastify = require('fastify');
const WebSocket = require('ws');
const { setupDatabase } = require('./database/connection');
const { setupMiddleware } = require('./middleware');
const { setupRoutes } = require('./routes');
const { setupWebSocket } = require('./services/websocket');
const { setupMatchingEngine } = require('./services/matchingEngine');

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

    console.log('Rant.Zone backend initialized successfully');

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