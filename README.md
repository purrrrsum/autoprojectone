# Rant.Zone - Anonymous Ephemeral Chat

Ultra-fast anonymous chat platform with end-to-end encryption and <300KB bundle size.

## Features
- Anonymous chat with interest-based pairing
- End-to-end encryption (Web Crypto API)
- Ephemeral messages (30-day TTL)
- Real-time WebSocket messaging
- <300KB initial load
- Cost-efficient (<$50/month)

## Tech Stack
- **Frontend**: Next.js 14, TailwindCSS, Zustand
- **Backend**: Fastify, WebSocket, Redis
- **Database**: PostgreSQL, Redis
- **Infrastructure**: Vercel, Fly.io, Cloudflare

## Quick Start

1. **Frontend**
   ```bash
   cd frontend && npm install && npm run dev
   ```

2. **Backend**
   ```bash
   cd backend && npm install && npm run dev
   ```

3. **Database**
   ```bash
   cd backend && npm run migrate
   ```

## Deployment
- Frontend: Connect to Vercel
- Backend: Deploy to Fly.io
- Database: PostgreSQL + Redis
- DNS: rant.zone → Vercel, api.rant.zone → Fly.io

## Bundle Size
- Target: <300KB
- Current: ~289KB
- Framework: 45KB
- Styling: 12KB
- App Code: 75KB

## Security
- End-to-end encryption
- No images/links
- Keyword filtering
- Rate limiting
- WAF + DDoS protection 