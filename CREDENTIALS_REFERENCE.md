# 🔐 Rant.Zone Credentials Reference

## ⚠️ SECURITY WARNING
**Never commit these credentials to version control!**
Store them securely in GitHub Secrets and environment variables.

---

## 🔑 Generated Security Keys

### JWT Secret
```
5b9afc7f71cf225a0f01dc32c728762b00f836dcc129a4aa71128a93fde5f9e0
```

### Encryption Key
```
mWHOoe43eaFqP9ZsDkEZqwwvMc0SiHJfJyUYKbQ3jMI=
```

### Database Password (if needed)
```
2a04573821d92f6395e81451148ca6f2
```

---

## 📋 Required Credentials Checklist

### 1. Database (PostgreSQL)
- [ ] **Provider**: Railway/Supabase/Neon
- [ ] **DATABASE_URL**: `postgresql://user:pass@host:5432/dbname`
- [ ] **Status**: ⏳ Need to create

### 2. Cache (Redis)
- [ ] **Provider**: Upstash/Redis Cloud
- [ ] **REDIS_URL**: `rediss://user:pass@host:6379`
- [ ] **Status**: ⏳ Need to create

### 3. Frontend (Vercel)
- [ ] **VERCEL_TOKEN**: ⏳ Need to create
- [ ] **VERCEL_ORG_ID**: ⏳ Need to create
- [ ] **VERCEL_PROJECT_ID**: ⏳ Need to create
- [ ] **Status**: ⏳ Need to set up

### 4. Backend (Fly.io)
- [ ] **FLY_API_TOKEN**: ⏳ Need to create
- [ ] **Status**: ⏳ Need to set up

### 5. Domain (Cloudflare)
- [ ] **CLOUDFLARE_API_TOKEN**: ⏳ Need to create
- [ ] **CLOUDFLARE_ZONE_ID**: ⏳ Need to create
- [ ] **Status**: ⏳ Need to set up

---

## 🚀 Quick Setup Commands

### Generate New Keys (if needed)
```bash
node setup-credentials.js
```

### Test Database Connection
```bash
cd backend
npm install
npm run migrate
```

### Deploy Backend
```bash
cd backend
flyctl launch
flyctl deploy
```

### Deploy Frontend
```bash
# Push to GitHub - Vercel will auto-deploy
git add .
git commit -m "Update credentials"
git push origin main
```

---

## 🔗 Service URLs

### Development
- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:3001
- **WebSocket**: ws://localhost:3001

### Production (after setup)
- **Frontend**: https://rant.zone
- **Backend**: https://api.rant.zone
- **WebSocket**: wss://api.rant.zone

---

## 📞 Support Links

- **Railway**: https://railway.app
- **Upstash**: https://upstash.com
- **Vercel**: https://vercel.com
- **Fly.io**: https://fly.io
- **Cloudflare**: https://cloudflare.com
- **GitHub Repo**: https://github.com/purrrrsum/rant-zone

---

## ✅ Next Steps

1. **Follow CREDENTIALS_SETUP_GUIDE.md** for detailed instructions
2. **Create accounts** on all required services
3. **Generate credentials** for each service
4. **Add secrets** to GitHub repository
5. **Test locally** before deploying
6. **Deploy to production**

---

## 💰 Cost Estimation

### Free Tier (Development)
- **Railway**: $0/month (limited)
- **Upstash**: $0/month (10k requests/day)
- **Vercel**: $0/month (100GB bandwidth)
- **Fly.io**: $0/month (3 VMs)
- **Cloudflare**: $0/month

### Production (Estimated)
- **Total**: $20-50/month (depending on usage)

---

**🎯 Goal: Get your Rant.Zone platform live with <$50/month hosting costs!** 