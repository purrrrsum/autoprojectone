# 🚀 AWS Console Backend Deployment Guide

## 📋 **Prerequisites**
- ✅ AWS Account with proper permissions
- ✅ AWS CLI configured
- ✅ Docker installed and running
- ✅ Backend code ready

## 🎯 **Step-by-Step Deployment**

### **Step 1: Prepare Environment Variables**

First, let's store our secrets in AWS Systems Manager Parameter Store:

```bash
# Store database URL
aws ssm put-parameter \
    --name "/rant-zone/database-url" \
    --value "postgresql://postgres:mMUvgJdMloYFOtfsYIzPFBilkOCtmeUE@gondola.proxy.rlwy.net:52938/railway" \
    --type "SecureString" \
    --region us-east-1

# Store Redis URL
aws ssm put-parameter \
    --name "/rant-zone/redis-url" \
    --value "redis://social-oyster-7619.upstash.io:6379" \
    --type "SecureString" \
    --region us-east-1

# Store JWT Secret
aws ssm put-parameter \
    --name "/rant-zone/jwt-secret" \
    --value "c3ce712bd9150ddcfe3243a83db412a5154c6ebba3a4766bd080dd85f3adf107" \
    --type "SecureString" \
    --region us-east-1

# Store Encryption Key
aws ssm put-parameter \
    --name "/rant-zone/encryption-key" \
    --value "Rd/lbXUY6f0zLmCdjewVLvxTornEHddCDHFaVk3v+VA=" \
    --type "SecureString" \
    --region us-east-1
```

### **Step 2: Create ECR Repository**

1. **Go to AWS ECR Console**: https://console.aws.amazon.com/ecr/
2. **Click "Create repository"**
3. **Repository name**: `rant-zone-backend`
4. **Visibility**: Private
5. **Click "Create repository"**

### **Step 3: Build and Push Docker Image**

```bash
# Get ECR login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Build image
cd rant-zone-deploy/backend
docker build -t rant-zone-backend .

# Tag image
docker tag rant-zone-backend:latest YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/rant-zone-backend:latest

# Push image
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/rant-zone-backend:latest
```

### **Step 4: Create ECS Cluster**

1. **Go to AWS ECS Console**: https://console.aws.amazon.com/ecs/
2. **Click "Create cluster"**
3. **Cluster name**: `rant-zone-cluster`
4. **Networking**: Default VPC
5. **Click "Create"**

### **Step 5: Create Task Definition**

1. **In ECS Console, go to "Task Definitions"**
2. **Click "Create new Task Definition"**
3. **Select "Fargate"**
4. **Task Definition Name**: `rant-zone-backend-task`
5. **Task Role**: `ecsTaskExecutionRole`
6. **Task Memory**: 512 MB
7. **Task CPU**: 256 (.25 vCPU)

### **Step 6: Configure Container**

1. **Container name**: `rant-zone-backend`
2. **Image**: `YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/rant-zone-backend:latest`
3. **Port mappings**: 3001
4. **Environment variables**:
   - `NODE_ENV`: `production`
   - `PORT`: `3001`
   - `HOST`: `0.0.0.0`
   - `ALLOWED_ORIGINS`: `https://rant.zone,https://www.rant.zone,https://djxgybv2umfrz.cloudfront.net`
   - `RATE_LIMIT_MAX`: `100`
   - `RATE_LIMIT_WINDOW_MS`: `900000`
   - `WS_HEARTBEAT_INTERVAL`: `30000`
   - `WS_CONNECTION_TIMEOUT`: `60000`
   - `LOG_LEVEL`: `info`

5. **Secrets** (from Parameter Store):
   - `DATABASE_URL`: `/rant-zone/database-url`
   - `REDIS_URL`: `/rant-zone/redis-url`
   - `JWT_SECRET`: `/rant-zone/jwt-secret`
   - `ENCRYPTION_KEY`: `/rant-zone/encryption-key`

6. **Click "Create"**

### **Step 7: Create Service**

1. **In your cluster, click "Create Service"**
2. **Launch type**: Fargate
3. **Task Definition**: `rant-zone-backend-task`
4. **Service name**: `rant-zone-backend`
5. **Number of tasks**: 1
6. **Click "Next"**

### **Step 8: Configure Networking**

1. **VPC**: Default VPC
2. **Subnets**: Select 2 subnets
3. **Security Groups**: Create new or use existing
4. **Auto-assign public IP**: Enabled
5. **Click "Next"**

### **Step 9: Configure Load Balancer (Optional)**

1. **Load balancer type**: Application Load Balancer
2. **Target group**: Create new
3. **Health check path**: `/health`
4. **Click "Next"**

### **Step 10: Deploy**

1. **Click "Create Service"**
2. **Wait for deployment** (5-10 minutes)

## 🧪 **Testing Your Deployment**

### **Get Service URL**
1. **Go to your ECS service**
2. **Click on the task**
3. **Note the public IP address**
4. **Test**: `http://PUBLIC_IP:3001/health`

### **Expected Response**
```json
{
  "status": "ok",
  "timestamp": "2024-12-08T...",
  "database": "connected",
  "redis": "connected"
}
```

## 🔗 **Connect Frontend**

### **Update Frontend Environment Variables**
```javascript
// Update these in your frontend
NEXT_PUBLIC_API_URL=http://YOUR_PUBLIC_IP:3001
NEXT_PUBLIC_WEBSOCKET_URL=ws://YOUR_PUBLIC_IP:3001
```

### **Redeploy Frontend**
1. Update environment variables
2. Redeploy to S3/CloudFront
3. Test full application

## 🎯 **Next Steps**

### **1. Set up Load Balancer**
- Create Application Load Balancer
- Configure SSL certificate
- Set up custom domain

### **2. Configure Custom Domain**
- Point `api.rant.zone` to load balancer
- Set up SSL certificate
- Update frontend URLs

### **3. Production Optimization**
- Set up CloudWatch monitoring
- Configure auto-scaling
- Set up backup strategies

## 💰 **Cost Estimation**

### **Monthly Costs**
- **ECS Fargate**: ~$15-30 (depending on usage)
- **ECR**: ~$1-2 (storage)
- **Load Balancer**: ~$20 (if used)
- **Total**: ~$20-50/month

## 🚨 **Troubleshooting**

### **Common Issues**
1. **Task fails to start**: Check logs in CloudWatch
2. **Container can't connect**: Check security groups
3. **Environment variables**: Verify Parameter Store values
4. **Health check fails**: Check application logs

### **Useful Commands**
```bash
# Check task status
aws ecs describe-tasks --cluster rant-zone-cluster --tasks TASK_ID

# View logs
aws logs get-log-events --log-group-name /ecs/rant-zone-backend-task --log-stream-name STREAM_NAME

# Update service
aws ecs update-service --cluster rant-zone-cluster --service rant-zone-backend --force-new-deployment
```

---

**Ready to deploy? Follow the steps above and let me know if you encounter any issues!** 