# 🚀 Railway Backend Deployment Guide

## 📋 **Prerequisites**
- ✅ GitHub repository with backend code
- ✅ Railway account (free tier available)
- ✅ PostgreSQL database URL (already have from Railway)
- ✅ Redis URL (from Upstash)

## 🔧 **Step 1: Prepare Repository**

### **1.1 Create Railway Configuration**
- ✅ `railway.json` - Railway deployment config
- ✅ `Procfile` - Process definition
- ✅ `package.json` - Dependencies and scripts

### **1.2 Environment Variables Needed**
```bash
# Database
DATABASE_URL=postgresql://postgres:mMUvgJdMloYFOtfsYIzPFBilkOCtmeUE@gondola.proxy.rlwy.net:52938/railway

# Redis
REDIS_URL=redis://your-upstash-redis-url

# Security
JWT_SECRET=your-jwt-secret
ENCRYPTION_KEY=your-encryption-key

# Server
NODE_ENV=production
PORT=3001
HOST=0.0.0.0

# CORS
ALLOWED_ORIGINS=https://rant.zone,https://www.rant.zone,https://djxgybv2umfrz.cloudfront.net

# Rate Limiting
RATE_LIMIT_MAX=100
RATE_LIMIT_WINDOW_MS=900000

# WebSocket
WS_HEARTBEAT_INTERVAL=30000
WS_CONNECTION_TIMEOUT=60000
```

## 🌐 **Step 2: Deploy to Railway**

### **2.1 Go to Railway Console**
1. Open: https://railway.app/
2. Sign in with GitHub
3. Click **"New Project"**

### **2.2 Connect Repository**
1. Select **"Deploy from GitHub repo"**
2. Choose your repository: `rant-zone-deploy`
3. Railway will auto-detect it's a Node.js project

### **2.3 Configure Deployment**
1. **Service Name**: `rant-zone-backend`
2. **Root Directory**: `backend` (if your backend is in a subfolder)
3. **Build Command**: `npm install`
4. **Start Command**: `npm start`

### **2.4 Add Environment Variables**
1. Go to **"Variables"** tab
2. Add each environment variable from the list above
3. **Important**: Use your actual values for secrets

### **2.5 Deploy**
1. Click **"Deploy"**
2. Wait for build and deployment (2-5 minutes)
3. Railway will provide a URL like: `https://your-app.railway.app`

## 🧪 **Step 3: Test Deployment**

### **3.1 Health Check**
- Visit: `https://your-app.railway.app/health`
- Should return: `{"status":"ok","timestamp":"..."}`

### **3.2 API Endpoints**
- **Health**: `GET /health`
- **Chat**: `GET /api/chat`
- **Users**: `GET /api/users`
- **Interests**: `GET /api/interests`

### **3.3 WebSocket Connection**
- **URL**: `wss://your-app.railway.app`
- **Test**: Connect and send a test message

## 🔗 **Step 4: Connect Frontend**

### **4.1 Update Frontend Environment**
```javascript
// Update these in your frontend
NEXT_PUBLIC_API_URL=https://your-app.railway.app
NEXT_PUBLIC_WEBSOCKET_URL=wss://your-app.railway.app
```

### **4.2 Redeploy Frontend**
1. Update environment variables
2. Redeploy to S3/CloudFront
3. Test full application

## 🎯 **Step 5: Custom Domain (Optional)**

### **5.1 Add Custom Domain**
1. In Railway, go to **"Settings"**
2. Click **"Add Domain"**
3. Enter: `api.rant.zone`

### **5.2 Update DNS**
1. Add CNAME record in Route 53:
   ```
   Name: api
   Type: CNAME
   Value: your-app.railway.app
   TTL: 300
   ```

## 📊 **Expected Results**

### **✅ Success Indicators:**
- Railway deployment shows **"Deployed"** ✅
- Health check returns 200 OK ✅
- API endpoints respond correctly ✅
- WebSocket connection works ✅
- Frontend can connect to backend ✅

### **❌ Common Issues:**
- **Build fails**: Check package.json and dependencies
- **Environment variables**: Verify all required vars are set
- **Database connection**: Check DATABASE_URL format
- **CORS errors**: Verify ALLOWED_ORIGINS includes frontend URL

## 💰 **Costs**
- **Railway Free Tier**: $5/month credit
- **PostgreSQL**: ~$5/month (already have)
- **Total**: ~$5-10/month

## 🚀 **Next Steps After Deployment**
1. **Test all API endpoints**
2. **Verify WebSocket functionality**
3. **Connect frontend to backend**
4. **Test full application flow**
5. **Set up monitoring and logging**

---

**Ready to deploy? Follow the steps above and let me know if you encounter any issues!** 