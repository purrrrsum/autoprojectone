# 🚀 AWS Backend Deployment Guide (Console-based)

## **Current Status**
- ✅ **Frontend**: Deployed to S3 + CloudFront
- ✅ **AWS Infrastructure**: ECS Cluster, ECR Repository ready
- ❌ **Docker Desktop**: WSL integration issues
- 🔄 **Backend**: Ready for AWS Console deployment

## **Solution: AWS Console Deployment**

Since Docker Desktop has WSL integration issues, we'll deploy using AWS Console and CodeBuild.

---

## **Step 1: Store Environment Variables in AWS SSM**

### **1.1 Open AWS Systems Manager Console**
1. Go to [AWS Systems Manager Console](https://console.aws.amazon.com/systems-manager/)
2. Navigate to **Parameter Store**
3. Click **Create parameter**

### **1.2 Create Parameters**
Create these parameters one by one:

**Database URL:**
- **Name**: `/rant-zone/database-url`
- **Type**: `SecureString`
- **Value**: `postgresql://postgres:mMUvgJdMloYFOtfsYIzPFBilkOCtmeUE@gondola.proxy.rlwy.net:52938/railway`

**Redis URL:**
- **Name**: `/rant-zone/redis-url`
- **Type**: `SecureString`
- **Value**: `redis://social-oyster-7619.upstash.io:6379`

**JWT Secret:**
- **Name**: `/rant-zone/jwt-secret`
- **Type**: `SecureString`
- **Value**: `c3ce712bd9150ddcfe3243a83db412a5154c6ebba3a4766bd080dd85f3adf107`

**Encryption Key:**
- **Name**: `/rant-zone/encryption-key`
- **Type**: `SecureString`
- **Value**: `Rd/lbXUY6f0zLmCdjewVLvxTornEHddCDHFaVk3v+VA=`

---

## **Step 2: Create AWS CodeBuild Project**

### **2.1 Open CodeBuild Console**
1. Go to [AWS CodeBuild Console](https://console.aws.amazon.com/codesuite/codebuild/)
2. Click **Create build project**

### **2.2 Configure Project**
- **Project name**: `rant-zone-backend-build`
- **Source provider**: `GitHub`
- **Repository**: `Connect using OAuth`
- **Repository URL**: `https://github.com/purrrrsum/autoprojectone`
- **Source version**: `main`

### **2.3 Environment Configuration**
- **Environment image**: `Managed image`
- **Operating system**: `Ubuntu`
- **Runtime**: `Standard`
- **Image**: `aws/codebuild/amazonlinux2-x86_64-standard:4.0`
- **Compute resources**: `Use this build project's compute resources`
- **Service role**: `New service role`
- **Role name**: `codebuild-rant-zone-backend-build-service-role`

### **2.4 Buildspec Configuration**
- **Buildspec name**: `buildspec.yml`
- **Use a buildspec file**: `Yes`

### **2.5 Artifacts**
- **Type**: `No artifacts`

### **2.6 Logs**
- **CloudWatch logs**: `Enabled`
- **Group name**: `/aws/codebuild/rant-zone-backend-build`
- **Stream name**: `build-log`

Click **Create build project**

---

## **Step 3: Create buildspec.yml**

### **3.1 Create buildspec.yml in your repository**
Add this file to your GitHub repository root:

```yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 224776848598.dkr.ecr.us-east-1.amazonaws.com
      - REPOSITORY_URI=224776848598.dkr.ecr.us-east-1.amazonaws.com/rant-zone-backend
      - IMAGE_TAG=latest
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - cd backend
      - docker build -f Dockerfile.aws -t $REPOSITORY_URI:$IMAGE_TAG .
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo Writing image definitions file...
      - printf '[{"name":"rant-zone-backend","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json
artifacts:
  files:
    - imagedefinitions.json
```

---

## **Step 4: Create ECS Task Definition**

### **4.1 Open ECS Console**
1. Go to [AWS ECS Console](https://console.aws.amazon.com/ecs/)
2. Navigate to **Task Definitions**
3. Click **Create new Task Definition**

### **4.2 Configure Task Definition**
- **Task Definition Name**: `rant-zone-backend`
- **Task Role**: `ecsTaskExecutionRole`
- **Task execution role**: `ecsTaskExecutionRole`
- **Task memory**: `512 MB`
- **Task CPU**: `256 (.25 vCPU)`

### **4.3 Add Container**
Click **Add container** and configure:

**Container name**: `rant-zone-backend`
**Image**: `224776848598.dkr.ecr.us-east-1.amazonaws.com/rant-zone-backend:latest`
**Memory limits**: `512 MB`
**Port mappings**: `3001:3001`

**Environment variables**:
- `NODE_ENV`: `production`
- `PORT`: `3001`

**Secrets** (from Parameter Store):
- `DATABASE_URL`: `/rant-zone/database-url`
- `REDIS_URL`: `/rant-zone/redis-url`
- `JWT_SECRET`: `/rant-zone/jwt-secret`
- `ENCRYPTION_KEY`: `/rant-zone/encryption-key`

**Health check**:
- **Command**: `["CMD-SHELL", "curl -f http://localhost:3001/health || exit 1"]`
- **Interval**: `30 seconds`
- **Timeout**: `5 seconds`
- **Retries**: `3`
- **Start period**: `60 seconds`

Click **Add** and then **Create**

---

## **Step 5: Create ECS Service**

### **5.1 Open ECS Cluster**
1. Go to your `rant-zone-cluster`
2. Click **Create Service**

### **5.2 Configure Service**
- **Launch type**: `FARGATE`
- **Task Definition**: `rant-zone-backend`
- **Service name**: `rant-zone-backend-service`
- **Number of tasks**: `1`

### **5.3 Network Configuration**
- **VPC**: `Default VPC`
- **Subnets**: Select all available subnets
- **Security groups**: Create new security group
  - **Name**: `rant-zone-backend-sg`
  - **Description**: `Security group for Rant.Zone backend`
  - **Inbound rules**: 
    - `TCP 3001` from `0.0.0.0/0` (for health checks)
    - `TCP 80` from `0.0.0.0/0` (for ALB)
    - `TCP 443` from `0.0.0.0/0` (for ALB)

### **5.4 Load Balancer (Optional)**
- **Load balancer type**: `Application Load Balancer`
- **Service IAM role**: `AWSServiceRoleForECS`
- **Target group**: Create new
  - **Target group name**: `rant-zone-backend-tg`
  - **Target type**: `IP`
  - **Protocol**: `HTTP`
  - **Port**: `3001`
  - **Health check path**: `/health`

Click **Create Service**

---

## **Step 6: Test Backend**

### **6.1 Get Service URL**
1. Go to your ECS service
2. Note the public IP address of the running task
3. Test: `http://[PUBLIC_IP]:3001/health`

### **6.2 Update Frontend**
Update your frontend environment variables to point to the new backend:

```javascript
// In your frontend configuration
NEXT_PUBLIC_API_URL=http://[PUBLIC_IP]:3001
NEXT_PUBLIC_WEBSOCKET_URL=ws://[PUBLIC_IP]:3001
```

---

## **Step 7: Set up Application Load Balancer (Recommended)**

### **7.1 Create ALB**
1. Go to [EC2 Console > Load Balancers](https://console.aws.amazon.com/ec2/v2/home#LoadBalancers)
2. Click **Create Load Balancer**
3. Select **Application Load Balancer**

### **7.2 Configure ALB**
- **Name**: `rant-zone-alb`
- **Scheme**: `internet-facing`
- **IP address type**: `ipv4`
- **VPC**: `Default VPC`
- **Subnets**: Select all available subnets

### **7.3 Configure Listeners**
- **Listener**: `HTTP:80`
- **Default action**: `Forward to rant-zone-backend-tg`

### **7.4 Security Groups**
- **Security group**: Create new
  - **Name**: `rant-zone-alb-sg`
  - **Inbound rules**:
    - `HTTP 80` from `0.0.0.0/0`
    - `HTTPS 443` from `0.0.0.0/0`

Click **Create load balancer**

---

## **Step 8: Update DNS and SSL**

### **8.1 Request SSL Certificate**
1. Go to [Certificate Manager](https://console.aws.amazon.com/acm/)
2. Request certificate for `api.rant.zone`
3. Validate via DNS

### **8.2 Update ALB Listener**
1. Add HTTPS listener (port 443)
2. Attach SSL certificate
3. Redirect HTTP to HTTPS

### **8.3 Update DNS**
In Hostinger DNS settings:
- **Type**: `A`
- **Name**: `api`
- **Value**: `[ALB_DNS_NAME]`
- **TTL**: `300`

---

## **🎉 Deployment Complete!**

### **Final URLs:**
- **Frontend**: `https://rant.zone`
- **Backend API**: `https://api.rant.zone`
- **WebSocket**: `wss://api.rant.zone`

### **Monitoring:**
- **ECS Console**: Monitor service health
- **CloudWatch**: View logs and metrics
- **CodeBuild**: Monitor build status

### **Next Steps:**
1. Test full application flow
2. Set up monitoring and alerts
3. Configure auto-scaling
4. Set up backup strategies

---

## **Troubleshooting**

### **If CodeBuild Fails:**
1. Check build logs in CloudWatch
2. Verify GitHub repository access
3. Check IAM permissions

### **If ECS Service Fails:**
1. Check task logs in CloudWatch
2. Verify environment variables
3. Check security group rules

### **If Health Checks Fail:**
1. Verify `/health` endpoint exists
2. Check container port configuration
3. Verify security group allows traffic

---

**Need Help?** Check the AWS Console logs and CloudWatch for detailed error messages. 