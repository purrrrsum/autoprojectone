# Anonymous Ephemeral Chat Platform

A high-performance, anonymous chat platform with end-to-end encryption and real-time messaging.

## 🚀 Features

- **Anonymous Chat**: No registration required, instant pairing
- **Interest-Based Matching**: Connect with users sharing similar interests
- **End-to-End Encryption**: Messages encrypted using Web Crypto API
- **Ephemeral Messages**: Auto-delete after 30 days
- **Real-Time Messaging**: WebSocket-based instant communication
- **Gender Selection**: Optional gender-based matching (skippable)
- **Ultra-Fast Performance**: <250KB initial bundle size
- **Responsive Design**: Works on all devices

## 🛠 Tech Stack

### Frontend
- **Framework**: Next.js 14 with Preact optimization
- **Styling**: TailwindCSS with JIT compilation
- **State Management**: Zustand
- **Encryption**: Browser Web Crypto API
- **Real-time**: Native WebSocket API

### Backend
- **Runtime**: Node.js 18+
- **Framework**: Fastify
- **WebSocket**: Native WebSocket server
- **Matching Engine**: Redis Pub/Sub
- **Database**: PostgreSQL + Redis

### Infrastructure
- **Frontend Hosting**: Vercel (Global CDN)
- **Backend Hosting**: Fly.io (Dockerized)
- **Security**: Cloudflare WAF + DDoS protection
- **CI/CD**: GitHub Actions

## 📦 Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL
- Redis

### Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

### Backend Setup
```bash
cd backend
npm install
cp env.example .env
# Configure environment variables
npm run dev
```

## 🔧 Environment Variables

### Frontend (.env.local)
```env
NEXT_PUBLIC_API_URL=https://api.rant.zone
NEXT_PUBLIC_WEBSOCKET_URL=wss://api.rant.zone
NEXT_PUBLIC_APP_ENV=development
```

### Backend (.env)
```env
DATABASE_URL=postgresql://user:pass@host:5432/dbname
REDIS_URL=rediss://user:pass@host:6379
JWT_SECRET=your-secret-key
NODE_ENV=production
```

## 🚀 Deployment

### Frontend (Vercel)
1. Connect GitHub repository
2. Configure environment variables
3. Deploy automatically

### Backend (Fly.io)
1. Install Fly CLI
2. Run `fly deploy`
3. Configure secrets

## 📊 Performance

- **Initial Load**: <250KB
- **Time to Interactive**: <2s
- **Bundle Optimization**: Advanced tree shaking
- **Caching**: Global CDN with edge caching

## 🔒 Security

- **Encryption**: AES-GCM with ECDH key exchange
- **Authentication**: JWT tokens
- **Rate Limiting**: Built-in protection
- **Content Moderation**: Keyword filtering
- **HTTPS**: TLS 1.3 enforced

## 📈 Monitoring

- **Bundle Analysis**: Automated size checking
- **Error Tracking**: Comprehensive logging
- **Performance**: Real-time metrics
- **Uptime**: Health checks

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Run tests
5. Submit pull request

## 📄 License

MIT License - see LICENSE file for details 

## 🔐 Authentication & Deployment Setup

### Centralized Configuration

This project uses a centralized authentication system for secure deployment:

#### Files Created:
- `config/production.env` - Environment variables for production
- `config/auth-config.json` - Structured configuration for all services
- `scripts/deploy.js` - Automated deployment script
- `scripts/setup-github-secrets.js` - GitHub Secrets setup guide

#### Quick Setup:

1. **Update Configuration**:
   ```bash
   # Edit config/auth-config.json with your actual values
   # Replace all "your-*" placeholders with real credentials
   ```

2. **Set GitHub Secrets**:
   ```bash
   node scripts/setup-github-secrets.js
   # Copy the output to GitHub Repository Secrets
   ```

3. **Deploy**:
   ```bash
   # Manual deployment
   node scripts/deploy.js
   
   # Or push to main branch for automated deployment
   git push origin main
   ```

#### Required Secrets:

**Vercel:**
- `VERCEL_TOKEN`
- `VERCEL_PROJECT_ID` 
- `VERCEL_ORG_ID`

**Fly.io:**
- `FLY_API_TOKEN`
- `FLY_APP_NAME`

**Database:**
- `DATABASE_URL` (Railway PostgreSQL)

**Redis:**
- `REDIS_URL` (Upstash)

**Security:**
- `JWT_SECRET`
- `ENCRYPTION_KEY`

### Security Notes:
- Never commit `config/production.env` or `config/auth-config.json`
- Use GitHub Secrets for CI/CD
- Rotate secrets regularly
- Monitor access logs 
