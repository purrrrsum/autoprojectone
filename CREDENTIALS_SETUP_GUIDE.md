# Rant.Zone Credentials & Hosting Setup Guide

## 🎯 Overview
This guide will help you set up all required credentials and hosting services for your Rant.Zone project.

## 📋 Required Services & Credentials

### 1. Database (PostgreSQL)
### 2. Cache (Redis)
### 3. Frontend Hosting (Vercel)
### 4. Backend Hosting (Fly.io)
### 5. Domain & CDN (Cloudflare)
### 6. GitHub Secrets

---

## 🗄️ 1. PostgreSQL Database Setup

### Option A: Railway (Recommended - Free Tier)
1. **Sign Up**: Go to [railway.app](https://railway.app)
2. **Create Account**: Use GitHub login
3. **Create Project**: Click "New Project"
4. **Add Database**: 
   - Click "Provision PostgreSQL"
   - Wait for database to be created
5. **Get Credentials**:
   - Click on PostgreSQL service
   - Go to "Connect" tab
   - Copy the `DATABASE_URL`

### Option B: Supabase (Alternative - Free Tier)
1. **Sign Up**: Go to [supabase.com](https://supabase.com)
2. **Create Project**: 
   - Click "New Project"
   - Choose organization
   - Enter project name: `rant-zone`
   - Set database password
   - Choose region (closest to you)
3. **Get Credentials**:
   - Go to Settings → Database
   - Copy the connection string

### Option C: Neon (Alternative - Free Tier)
1. **Sign Up**: Go to [neon.tech](https://neon.tech)
2. **Create Project**:
   - Click "Create Project"
   - Enter project name: `rant-zone`
   - Choose region
3. **Get Credentials**:
   - Copy the connection string from dashboard

---

## 🔴 2. Redis Cache Setup

### Option A: Upstash (Recommended - Free Tier)
1. **Sign Up**: Go to [upstash.com](https://upstash.com)
2. **Create Database**:
   - Click "Create Database"
   - Name: `rant-zone-cache`
   - Region: Choose closest to your PostgreSQL
   - TLS: Enabled
3. **Get Credentials**:
   - Copy the `UPSTASH_REDIS_REST_URL`
   - Copy the `UPSTASH_REDIS_REST_TOKEN`

### Option B: Redis Cloud (Alternative)
1. **Sign Up**: Go to [redis.com](https://redis.com)
2. **Create Database**:
   - Choose free plan
   - Select region
   - Create database
3. **Get Credentials**:
   - Copy the connection string

---

## ⚡ 3. Vercel Frontend Setup

### Step 1: Create Vercel Account
1. **Sign Up**: Go to [vercel.com](https://vercel.com)
2. **Login**: Use GitHub account
3. **Authorize**: Grant Vercel access to your GitHub

### Step 2: Import Repository
1. **Dashboard**: Go to Vercel dashboard
2. **New Project**: Click "New Project"
3. **Import Git**: Select your `rant-zone` repository
4. **Configure**:
   - Framework Preset: Next.js
   - Root Directory: `frontend`
   - Build Command: `npm run build`
   - Output Directory: `.next`
   - Install Command: `npm install`

### Step 3: Environment Variables
Add these environment variables in Vercel:
```
NEXT_PUBLIC_API_URL=https://api.rant.zone
NEXT_PUBLIC_WEBSOCKET_URL=wss://api.rant.zone
NEXT_PUBLIC_APP_ENV=production
```

### Step 4: Get Vercel Credentials
1. **Account Settings**: Go to Settings → Tokens
2. **Create Token**: 
   - Name: `rant-zone-deploy`
   - Expiration: No expiration
   - Copy the token
3. **Get Project ID**:
   - Go to your project settings
   - Copy the Project ID
4. **Get Org ID**:
   - Go to Account Settings
   - Copy the Team ID

---

## 🚀 4. Fly.io Backend Setup

### Step 1: Install Fly CLI
```bash
# Windows
winget install flyctl

# Or download from: https://fly.io/docs/hands-on/install-flyctl/
```

### Step 2: Create Fly Account
1. **Sign Up**: Go to [fly.io](https://fly.io)
2. **Create Account**: Use GitHub login
3. **Verify Email**: Check your email

### Step 3: Login to Fly CLI
```bash
flyctl auth login
```

### Step 4: Create Fly App
```bash
# Navigate to backend directory
cd backend

# Launch app
flyctl launch

# Follow prompts:
# - App name: rant-zone-backend
# - Region: Choose closest to you
# - Postgres: No (we'll use external)
# - Redis: No (we'll use external)
```

### Step 5: Set Environment Variables
```bash
flyctl secrets set DATABASE_URL="your-postgresql-url"
flyctl secrets set REDIS_URL="your-redis-url"
flyctl secrets set JWT_SECRET="your-jwt-secret"
flyctl secrets set ENCRYPTION_KEY="your-encryption-key"
flyctl secrets set NODE_ENV="production"
flyctl secrets set PORT="3000"
```

### Step 6: Get Fly Credentials
1. **API Token**: Go to [fly.io/account/api-tokens](https://fly.io/account/api-tokens)
2. **Create Token**: 
   - Name: `rant-zone-deploy`
   - Copy the token

---

## 🌐 5. Cloudflare Setup

### Step 1: Create Cloudflare Account
1. **Sign Up**: Go to [cloudflare.com](https://cloudflare.com)
2. **Add Domain**: 
   - Enter your domain (e.g., `rant.zone`)
   - Or use a subdomain of your existing domain

### Step 2: Configure DNS
1. **DNS Records**: Add these records:
   ```
   Type: A
   Name: @
   Content: [Your Vercel IP] (Vercel will provide)
   
   Type: CNAME
   Name: api
   Content: rant-zone-backend.fly.dev
   ```

### Step 3: Enable Features
1. **SSL/TLS**: Set to "Full (strict)"
2. **Security**: Enable WAF
3. **Performance**: Enable CDN

### Step 4: Get Cloudflare Credentials
1. **API Token**: Go to My Profile → API Tokens
2. **Create Token**:
   - Permissions: Zone → Zone → Edit
   - Zone Resources: Include → Specific zone → rant.zone
   - Copy the token
3. **Zone ID**: Copy from the Overview page

---

## 🔐 6. Generate Security Keys

### JWT Secret
```bash
# Generate a random 32-character string
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### Encryption Key
```bash
# Generate a 256-bit key (base64 encoded)
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

---

## ⚙️ 7. GitHub Secrets Setup

### Step 1: Go to GitHub Repository
1. Navigate to: https://github.com/purrrrsum/rant-zone
2. Go to Settings → Secrets and variables → Actions

### Step 2: Add Repository Secrets
Add these secrets one by one:

```
DATABASE_URL=postgresql://user:pass@host:5432/dbname
REDIS_URL=rediss://user:pass@host:6379
JWT_SECRET=your-generated-jwt-secret
ENCRYPTION_KEY=your-generated-encryption-key
FLY_API_TOKEN=your-fly-api-token
VERCEL_TOKEN=your-vercel-token
VERCEL_ORG_ID=your-vercel-org-id
VERCEL_PROJECT_ID=your-vercel-project-id
NEXT_PUBLIC_API_URL=https://api.rant.zone
NEXT_PUBLIC_WEBSOCKET_URL=wss://api.rant.zone
CLOUDFLARE_API_TOKEN=your-cloudflare-token
CLOUDFLARE_ZONE_ID=your-cloudflare-zone-id
```

---

## 🧪 8. Test Your Setup

### Step 1: Test Database Connection
```bash
# In backend directory
npm install
npm run migrate
```

### Step 2: Test Backend Locally
```bash
# Set environment variables
cp env.example .env
# Edit .env with your credentials

# Start server
npm run dev
```

### Step 3: Test Frontend Locally
```bash
# In frontend directory
npm install
npm run dev
```

---

## 🚀 9. Deploy to Production

### Step 1: Deploy Backend
```bash
# In backend directory
flyctl deploy
```

### Step 2: Deploy Frontend
1. **Push to GitHub**: Your changes will trigger Vercel deployment
2. **Check Vercel**: Monitor deployment in Vercel dashboard

### Step 3: Verify Deployment
1. **Backend**: https://rant-zone-backend.fly.dev/health
2. **Frontend**: https://rant.zone (or your Vercel URL)

---

## 📊 10. Monitoring & Maintenance

### Set Up Monitoring
1. **Vercel Analytics**: Enable in project settings
2. **Fly.io Monitoring**: Check app metrics
3. **Database Monitoring**: Use provider dashboard

### Regular Maintenance
1. **Security Updates**: Keep dependencies updated
2. **Backup Database**: Set up automated backups
3. **Monitor Costs**: Check usage in each platform

---

## 🔧 Troubleshooting

### Common Issues
1. **Database Connection**: Check DATABASE_URL format
2. **Redis Connection**: Verify REDIS_URL
3. **CORS Issues**: Check CORS_ORIGIN in backend
4. **WebSocket Issues**: Verify WebSocket URL

### Support Resources
- [Railway Docs](https://docs.railway.app)
- [Vercel Docs](https://vercel.com/docs)
- [Fly.io Docs](https://fly.io/docs)
- [Cloudflare Docs](https://developers.cloudflare.com)

---

## 💰 Cost Estimation

### Free Tier Limits
- **Railway**: $5/month after free tier
- **Upstash**: 10,000 requests/day free
- **Vercel**: 100GB bandwidth/month free
- **Fly.io**: 3 shared-cpu-1x 256mb VMs free
- **Cloudflare**: Free tier available

### Estimated Monthly Cost
- **Development**: $0-10/month
- **Production**: $20-50/month (depending on usage)

---

## ✅ Checklist

- [ ] PostgreSQL database created
- [ ] Redis cache configured
- [ ] Vercel account and project set up
- [ ] Fly.io account and app created
- [ ] Cloudflare domain configured
- [ ] Security keys generated
- [ ] GitHub secrets added
- [ ] Local testing completed
- [ ] Production deployment successful
- [ ] Monitoring configured

**Your Rant.Zone platform is now ready for production! 🎉** 