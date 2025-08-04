# AWS Deployment Guide for Rant.Zone

This guide will walk you through deploying the Rant.Zone application on AWS using Terraform infrastructure as code.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CloudFront    │    │   Route53 DNS   │    │   ACM SSL Cert  │
│   (CDN)         │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   S3 Bucket     │    │   WAF Rules     │    │   VPC Network   │
│   (Frontend)    │    │   (Security)    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │   Load Balancer │    │   ECS Cluster   │
│   Load Balancer │◄───┤   (ALB)         │◄───┤   (Backend)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   RDS Database  │    │   ElastiCache   │    │   CloudWatch    │
│   (PostgreSQL)  │    │   (Redis)       │    │   (Monitoring)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

### 1. AWS Account Setup
- AWS account with appropriate permissions
- AWS CLI installed and configured
- Domain name (rant.zone) registered in Route53

### 2. Required Tools
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs)"
sudo apt-get update && sudo apt-get install terraform

# Install Docker
sudo apt-get update
sudo apt-get install docker.io
sudo usermod -aG docker $USER

# Install jq (JSON processor)
sudo apt-get install jq
```

### 3. AWS Permissions
Your AWS user/role needs the following permissions:
- IAM (for creating roles and policies)
- S3 (for static hosting and Terraform state)
- CloudFront (for CDN)
- Route53 (for DNS management)
- ACM (for SSL certificates)
- VPC (for networking)
- EC2 (for ECS)
- ECS (for container orchestration)
- ECR (for container registry)
- RDS (for database)
- ElastiCache (for Redis)
- CloudWatch (for monitoring)
- WAF (for security)
- CodeBuild/CodePipeline (for CI/CD)

## 🚀 Deployment Steps

### Step 1: Configure AWS Credentials

```bash
# Configure AWS CLI
aws configure

# Enter your credentials:
# AWS Access Key ID: [your-access-key]
# AWS Secret Access Key: [your-secret-key]
# Default region name: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

### Step 2: Update Configuration

Edit `config/aws-config.json` with your specific values:

```json
{
  "aws": {
    "region": "us-east-1",
    "account_id": "123456789012",  // Your AWS account ID
    "profile": "default"
  },
  "networking": {
    "route53": {
      "hosted_zone_id": "Z1234567890ABC",  // Your Route53 hosted zone ID
      "domain_name": "rant.zone"
    }
  }
}
```

### Step 3: Generate Secrets

```bash
# Generate secure passwords and keys
cd rant-zone-deploy
node scripts/generate-secrets.js

# Update the generated secrets in aws-config.json
```

### Step 4: Deploy Infrastructure

```bash
# Make deployment script executable
chmod +x scripts/deploy-aws.sh

# Run the deployment
./scripts/deploy-aws.sh
```

The deployment script will:
1. ✅ Create Terraform state bucket
2. ✅ Deploy all AWS infrastructure
3. ✅ Build and push backend Docker image
4. ✅ Deploy frontend to S3/CloudFront
5. ✅ Configure DNS records
6. ✅ Run health checks

## 🔧 Manual Deployment (Alternative)

If you prefer to deploy manually:

### 1. Deploy Infrastructure
```bash
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=tfplan

# Apply deployment
terraform apply tfplan
```

### 2. Build and Deploy Backend
```bash
cd backend

# Build Docker image
docker build -f Dockerfile.aws -t rant-zone-backend .

# Get ECR repository URL from Terraform outputs
ECR_REPO_URL=$(terraform output -raw ecr_repository_url)

# Tag and push
docker tag rant-zone-backend:latest $ECR_REPO_URL:latest
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REPO_URL
docker push $ECR_REPO_URL:latest
```

### 3. Deploy Frontend
```bash
cd frontend

# Build frontend
npm install
npm run build

# Get S3 bucket from Terraform outputs
S3_BUCKET=$(terraform output -raw s3_bucket_name)

# Sync to S3
aws s3 sync .next/static s3://$S3_BUCKET/_next/static --cache-control "public, max-age=31536000, immutable"
aws s3 sync public s3://$S3_BUCKET --cache-control "public, max-age=3600"
aws s3 sync .next s3://$S3_BUCKET --exclude "static/*" --cache-control "public, max-age=0, must-revalidate"

# Invalidate CloudFront cache
CLOUDFRONT_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_ID --paths "/*"
```

## 🔍 Verification

### Check Infrastructure
```bash
# Verify all resources are created
aws ecs list-services --cluster rant-zone-cluster
aws rds describe-db-instances --db-instance-identifier rant-zone-db
aws elasticache describe-cache-clusters --cache-cluster-id rant-zone-redis
```

### Test Application
```bash
# Test frontend
curl -I https://rant.zone

# Test backend
curl -I https://api.rant.zone/health

# Test WebSocket
wscat -c wss://api.rant.zone
```

## 📊 Monitoring

### CloudWatch Dashboards
- **ECS Metrics**: CPU, Memory, Network
- **RDS Metrics**: Connections, CPU, Storage
- **Application Metrics**: Response time, Error rate

### Alarms
- CPU utilization > 80%
- Memory utilization > 80%
- Database connections > 80%
- Application errors > 5%

## 🔒 Security

### WAF Rules
- Rate limiting: 2000 requests per 5 minutes
- Blocked IP addresses
- SQL injection protection
- XSS protection

### Network Security
- VPC with public/private subnets
- Security groups with minimal access
- SSL/TLS encryption everywhere
- Database encryption at rest

## 💰 Cost Optimization

### Free Tier Usage
- **RDS**: db.t3.micro (750 hours/month)
- **EC2**: t3.micro (750 hours/month)
- **S3**: 5GB storage
- **CloudFront**: 1TB data transfer

### Estimated Monthly Costs (Production)
- **RDS**: $15-25/month
- **ECS**: $20-40/month
- **S3**: $5-10/month
- **CloudFront**: $10-20/month
- **ElastiCache**: $15-25/month
- **Total**: $65-120/month

## 🛠️ Troubleshooting

### Common Issues

#### 1. Terraform State Lock
```bash
# If Terraform gets stuck
terraform force-unlock [LOCK_ID]
```

#### 2. ECS Service Not Starting
```bash
# Check ECS service events
aws ecs describe-services --cluster rant-zone-cluster --services rant-zone-backend

# Check task logs
aws logs describe-log-groups --log-group-name-prefix "/aws/ecs/rant-zone-backend"
```

#### 3. DNS Not Propagating
```bash
# Check DNS records
aws route53 list-resource-record-sets --hosted-zone-id [ZONE_ID]

# Test DNS resolution
nslookup rant.zone
nslookup api.rant.zone
```

#### 4. SSL Certificate Issues
```bash
# Check certificate status
aws acm list-certificates --query 'CertificateSummaryList[?DomainName==`rant.zone`]'
```

## 🔄 CI/CD Pipeline

### Automated Deployment
The infrastructure includes CodeBuild and CodePipeline for automated deployments:

1. **Source**: CodeCommit repository
2. **Build**: CodeBuild with Docker
3. **Deploy**: ECS service update

### Manual Pipeline Trigger
```bash
# Trigger pipeline manually
aws codepipeline start-pipeline-execution --name rant-zone-pipeline
```

## 📝 Maintenance

### Regular Tasks
- **Weekly**: Review CloudWatch metrics
- **Monthly**: Update security patches
- **Quarterly**: Review and optimize costs
- **Annually**: Update SSL certificates

### Backup Strategy
- **RDS**: Automated daily backups (7-day retention)
- **S3**: Versioning enabled
- **Terraform State**: S3 backend with versioning

## 🆘 Support

### AWS Support
- **Basic**: Email support
- **Developer**: 12-hour response
- **Business**: 4-hour response
- **Enterprise**: 1-hour response

### Documentation
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

## ✅ Deployment Checklist

- [ ] AWS CLI configured
- [ ] Terraform installed
- [ ] Docker installed
- [ ] Domain registered in Route53
- [ ] Configuration updated
- [ ] Secrets generated
- [ ] Infrastructure deployed
- [ ] Backend deployed
- [ ] Frontend deployed
- [ ] DNS configured
- [ ] SSL certificates validated
- [ ] Health checks passing
- [ ] Monitoring configured
- [ ] Alarms set up
- [ ] Documentation updated

Your Rant.Zone application is now running on AWS! 🚀 