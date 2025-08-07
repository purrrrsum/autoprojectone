const healthRoutes = require('./health');
const apiRoutes = require('./api');

async function setupRoutes(app) {
  await app.register(healthRoutes, { prefix: '/health' });
  await app.register(apiRoutes, { prefix: '/api' });

  app.get('/', async (request, reply) => {
    return {
      name: 'Rant.Zone API',
      version: '1.0.0',
      status: 'running',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development'
    };
  });

  app.setNotFoundHandler(async (request, reply) => {
    return reply.status(404).send({
      error: 'Not Found',
      message: 'The requested resource was not found',
      path: request.url
    });
  });

  app.setErrorHandler(async (error, request, reply) => {
    console.error('Global error:', error);
    
    const errorDetails = {
      message: error.message,
      stack: error.stack,
      url: request.url,
      method: request.method,
      ip: request.ip,
      timestamp: new Date().toISOString()
    };

    console.error('Error details:', JSON.stringify(errorDetails, null, 2));

    if (error.statusCode) {
      return reply.status(error.statusCode).send({
        error: error.name || 'Error',
        message: error.message
      });
    }

    reply.status(500).send({
      error: 'Internal Server Error',
      message: process.env.NODE_ENV === 'production' 
        ? 'Something went wrong' 
        : error.message
    });
  });
}

module.exports = { setupRoutes }; 