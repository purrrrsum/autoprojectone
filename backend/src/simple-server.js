const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;
const HOST = process.env.HOST || '0.0.0.0';

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoints
app.get('/test', (req, res) => {
  res.json({ 
    message: 'Rant.Zone Backend is working!', 
    timestamp: new Date().toISOString(),
    status: 'healthy'
  });
});

app.get('/health/basic', (req, res) => {
  res.json({ status: 'healthy', service: 'rant-zone-backend' });
});

app.get('/health/full', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'rant-zone-backend',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.get('/health/live', (req, res) => {
  res.json({ status: 'alive' });
});

// Basic API endpoints
app.get('/api/status', (req, res) => {
  res.json({ status: 'Rant.Zone API is running!' });
});

app.post('/api/chat/join', (req, res) => {
  res.json({ 
    message: 'Chat join request received', 
    sessionId: 'demo-session-' + Date.now()
  });
});

// Catch all
app.get('*', (req, res) => {
  res.json({ 
    message: 'Rant.Zone Backend', 
    endpoint: req.path,
    method: req.method 
  });
});

app.listen(PORT, HOST, () => {
  console.log(`🚀 Rant.Zone Backend running on http://${HOST}:${PORT}`);
  console.log('✅ Health check available at /test');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});
