# Rant.Zone AWS Deployment Script (PowerShell)
# This script deploys the application to AWS using AWS CLI

param(
    [string]$Environment = "production"
)

Write-Host "🚀 Starting Rant.Zone AWS deployment..." -ForegroundColor Green

# Configuration
$ProjectName = "rant-zone"
$Region = "us-east-1"
$AccountId = "224776848598"

# Colors for output
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Blue = "Blue"

function Write-Step {
    param([string]$Message)
    Write-Host "📋 $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $Yellow
}

# Step 1: Create S3 bucket for frontend
Write-Step "Creating S3 bucket for frontend..."
try {
    aws s3 mb s3://$ProjectName-frontend --region $Region
    aws s3api put-bucket-website --bucket $ProjectName-frontend --website-configuration '{
        "IndexDocument": {"Suffix": "index.html"},
        "ErrorDocument": {"Key": "error.html"}
    }'
    Write-Success "S3 bucket created successfully"
} catch {
    Write-Warning "S3 bucket might already exist"
}

# Step 2: Create ECR repository for backend
Write-Step "Creating ECR repository for backend..."
try {
    aws ecr create-repository --repository-name $ProjectName-backend --region $Region
    Write-Success "ECR repository created successfully"
} catch {
    Write-Warning "ECR repository might already exist"
}

# Step 3: Create RDS database
Write-Step "Creating RDS database..."
try {
    # Create DB subnet group
    aws rds create-db-subnet-group `
        --db-subnet-group-name "$ProjectName-db-subnet-group" `
        --db-subnet-group-description "Subnet group for Rant.Zone database" `
        --subnet-ids subnet-12345678 subnet-87654321 `
        --region $Region

    # Create RDS instance
    aws rds create-db-instance `
        --db-instance-identifier "$ProjectName-db" `
        --db-instance-class "db.t3.micro" `
        --engine "postgres" `
        --engine-version "15.4" `
        --master-username "postgres" `
        --master-user-password "SecurePassword123!" `
        --allocated-storage 20 `
        --storage-type "gp2" `
        --db-subnet-group-name "$ProjectName-db-subnet-group" `
        --vpc-security-group-ids sg-12345678 `
        --backup-retention-period 7 `
        --region $Region

    Write-Success "RDS database creation initiated"
} catch {
    Write-Warning "RDS database might already exist or VPC not ready"
}

# Step 4: Create ElastiCache Redis
Write-Step "Creating ElastiCache Redis cluster..."
try {
    aws elasticache create-cache-subnet-group `
        --cache-subnet-group-name "$ProjectName-redis-subnet-group" `
        --cache-subnet-group-description "Subnet group for Rant.Zone Redis" `
        --subnet-ids subnet-12345678 subnet-87654321 `
        --region $Region

    aws elasticache create-cache-cluster `
        --cache-cluster-id "$ProjectName-redis" `
        --engine "redis" `
        --cache-node-type "cache.t3.micro" `
        --num-cache-nodes 1 `
        --cache-subnet-group-name "$ProjectName-redis-subnet-group" `
        --vpc-security-group-ids sg-12345678 `
        --region $Region

    Write-Success "ElastiCache Redis creation initiated"
} catch {
    Write-Warning "ElastiCache Redis might already exist or VPC not ready"
}

# Step 5: Create ECS cluster
Write-Step "Creating ECS cluster..."
try {
    aws ecs create-cluster --cluster-name "$ProjectName-cluster" --region $Region
    Write-Success "ECS cluster created successfully"
} catch {
    Write-Warning "ECS cluster might already exist"
}

# Step 6: Create Application Load Balancer
Write-Step "Creating Application Load Balancer..."
try {
    aws elbv2 create-load-balancer `
        --name "$ProjectName-alb" `
        --subnets subnet-12345678 subnet-87654321 `
        --security-groups sg-12345678 `
        --region $Region

    Write-Success "Application Load Balancer creation initiated"
} catch {
    Write-Warning "ALB might already exist or VPC not ready"
}

# Step 7: Create CloudFront distribution
Write-Step "Creating CloudFront distribution..."
try {
    aws cloudfront create-distribution `
        --distribution-config '{
            "CallerReference": "'$(Get-Date -Format "yyyyMMddHHmmss")'",
            "Origins": {
                "Quantity": 1,
                "Items": [
                    {
                        "Id": "S3-'$ProjectName-frontend'",
                        "DomainName": "'$ProjectName-frontend'.s3.amazonaws.com",
                        "S3OriginConfig": {
                            "OriginAccessIdentity": ""
                        }
                    }
                ]
            },
            "DefaultCacheBehavior": {
                "TargetOriginId": "S3-'$ProjectName-frontend'",
                "ViewerProtocolPolicy": "redirect-to-https",
                "TrustedSigners": {
                    "Enabled": false,
                    "Quantity": 0
                },
                "ForwardedValues": {
                    "QueryString": false,
                    "Cookies": {
                        "Forward": "none"
                    }
                },
                "MinTTL": 0
            },
            "Enabled": true,
            "Comment": "Rant.Zone frontend distribution"
        }' `
        --region $Region

    Write-Success "CloudFront distribution creation initiated"
} catch {
    Write-Warning "CloudFront distribution might already exist"
}

# Step 8: Update Route53 records
Write-Step "Updating Route53 DNS records..."
try {
    # Get hosted zone
    $HostedZoneId = "Z0607542AA2OSVN6D9DB"
    
    # Create A record for www.rant.zone
    aws route53 change-resource-record-sets `
        --hosted-zone-id $HostedZoneId `
        --change-batch '{
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "www.rant.zone",
                        "Type": "A",
                        "AliasTarget": {
                            "HostedZoneId": "Z2FDTNDATAQYW2",
                            "DNSName": "'$ProjectName-frontend'.s3-website-us-east-1.amazonaws.com",
                            "EvaluateTargetHealth": false
                        }
                    }
                }
            ]
        }' `
        --region $Region

    Write-Success "Route53 records updated successfully"
} catch {
    Write-Warning "Route53 update might have failed"
}

Write-Host "🎉 AWS infrastructure deployment completed!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Wait for RDS and ElastiCache to be available" -ForegroundColor Yellow
Write-Host "2. Build and push Docker images to ECR" -ForegroundColor Yellow
Write-Host "3. Deploy ECS services" -ForegroundColor Yellow
Write-Host "4. Configure environment variables" -ForegroundColor Yellow 