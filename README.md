# Rant.Zone - Anonymous Ephemeral Chat Platform

A production-ready anonymous ephemeral chat platform built with Next.js, Fastify, and WebSockets. Designed for ultra-fast performance, strong encryption, and cost-efficiency (<$50/month).

## 🚀 Features

- **Anonymous Chat Sessions**: Random pairing by interest (Science, Tech, Politics, Personal)
- **Ephemeral Messages**: Auto-delete after 30 days
- **End-to-End Encryption**: Using browser Web Crypto API
- **Ultra-Fast Performance**: <300KB initial load
- **Global CDN**: Low-latency access worldwide
- **Real-Time Messaging**: WebSocket-based communication
- **Basic Moderation**: Keyword filtering
- **Minimal Analytics**: Lazy loaded after interaction

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Infrastructure │
│   (Next.js)     │◄──►│   (Fastify)     │◄──►│   (Vercel/Fly)   │
│   <300KB        │    │   WebSocket     │    │   Global CDN     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Encryption    │    │   Matching      │    │   Database      │
│   (Web Crypto)  │    │   Engine        │    │   (PostgreSQL)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🛠️ Tech Stack

### Frontend
- **Framework**: Next.js (Preact production optimization)
- **Styling**: TailwindCSS JIT + PurgeCSS
- **State Management**: Zustand
- **Icons**: Inline SVG (Heroicons)
- **Encryption**: Browser Web Crypto API
- **WebSocket**: Native WebSocket API
- **Analytics**: Vercel Analytics (basic)

### Backend
- **Runtime**: Node.js + Fastify
- **Real-time**: Native WebSocket server
- **Matching Engine**: In-memory + Redis Pub/Sub
- **Moderation**: Simple keyword filter
- **Encryption**: End-to-end encryption with Web Crypto

### Database
- **Primary**: PostgreSQL (Railway/Supabase free tier)
- **Cache**: Redis (Upstash free tier)
- **Object Storage**: Supabase Storage or Backblaze B2

### Infrastructure
- **Frontend Host**: Vercel (Free tier, global CDN)
- **Backend Host**: Fly.io (Free tier, Dockerized WebSocket server)
- **Security**: Cloudflare (Free tier, WAF + DDoS protection)
- **CI/CD**: GitHub Actions (Free tier)

## 📦 Bundle Size Budget

- **Max Initial Load**: 300KB
- **Framework**: 50KB
- **Styling**: 15KB
- **State Management**: 2KB
- **App Code**: 80KB
- **Chat Lazy Load**: 60KB
- **Encryption**: 0KB (native browser API)
- **Icons/Fonts**: 0KB (inline SVG)
- **Analytics**: Lazy load after interaction

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Docker
- PostgreSQL
- Redis

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/rant-zone.git
   cd rant-zone
   ```

2. **Install dependencies**
   ```bash
   # Frontend
   cd frontend
   npm install
   
   # Backend
   cd ../backend
   npm install
   ```

3. **Set up environment variables**
   ```bash
   # Copy example env files
   cp frontend/.env.example frontend/.env.local
   cp backend/.env.example backend/.env
   ```

4. **Start development servers**
   ```bash
   # Terminal 1: Frontend
   cd frontend
   npm run dev
   
   # Terminal 2: Backend
   cd backend
   npm run dev
   ```

5. **Open your browser**
   - Frontend: http://localhost:3000
   - Backend: http://localhost:3001

## 🚀 Deployment

### One-Click Deployment

1. **Push to GitHub**
   ```bash
   git push origin main
   ```

2. **Deploy Frontend (Vercel)**
   - Connect GitHub repository to Vercel
   - Set environment variables
   - Deploy automatically

3. **Deploy Backend (Fly.io)**
   - Install Fly CLI: `curl -L https://fly.io/install.sh | sh`
   - Login: `fly auth login`
   - Deploy: `fly deploy`

4. **Configure DNS (Cloudflare)**
   - Point `rant.zone` to Vercel (frontend)
   - Point `api.rant.zone` to Fly.io (backend)

### Environment Variables

#### Vercel (Frontend)
```env
NEXT_PUBLIC_API_URL=https://api.rant.zone
NEXT_PUBLIC_WEBSOCKET_URL=wss://api.rant.zone
NEXT_PUBLIC_APP_ENV=production
```

#### Fly.io (Backend)
```env
DATABASE_URL=postgresql://<user>:<password>@<host>:5432/<dbname>
REDIS_URL=rediss://<user>:<password>@<host>:6379
JWT_SECRET=<random_generated_secret>
ENCRYPTION_KEY=<256_bit_key_base64>
NODE_ENV=production
```

## 🔒 Security Features

- **End-to-End Encryption**: All messages encrypted client-side
- **Ephemeral Storage**: Messages auto-delete after 30 days
- **No User Profiles**: Completely anonymous
- **No Images/Links**: Text-only communication
- **Keyword Filtering**: Basic content moderation
- **Rate Limiting**: Prevent abuse
- **DDoS Protection**: Cloudflare WAF

## 📊 Performance

- **Initial Load**: <300KB
- **Time to Interactive**: <2s
- **Global CDN**: <100ms latency
- **WebSocket**: Real-time messaging
- **Bundle Analysis**: Automated size checking

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

- **Issues**: GitHub Issues
- **Documentation**: This README
- **Security**: security@rant.zone

---

Built with ❤️ for anonymous, ephemeral conversations. 