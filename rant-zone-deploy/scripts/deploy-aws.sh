#!/bin/bash

# AWS Deployment Script for Rant.Zone
# This script sets up the complete AWS infrastructure and deploys the application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/config/aws-config.json"
TERRAFORM_DIR="$PROJECT_ROOT/infrastructure/terraform"

# Load configuration
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: AWS configuration file not found at $CONFIG_FILE${NC}"
    exit 1
fi

# Parse configuration
AWS_REGION=$(jq -r '.aws.region' "$CONFIG_FILE")
AWS_ACCOUNT_ID=$(jq -r '.aws.account_id' "$CONFIG_FILE")
DOMAIN_NAME=$(jq -r '.networking.route53.domain_name' "$CONFIG_FILE")

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi
}

check_terraform() {
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install it first."
        exit 1
    fi
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install it first."
        exit 1
    fi
}

setup_terraform_backend() {
    log_info "Setting up Terraform backend..."
    
    # Create S3 bucket for Terraform state
    BUCKET_NAME="rant-zone-terraform-state"
    
    if ! aws s3 ls "s3://$BUCKET_NAME" 2>&1 > /dev/null; then
        log_info "Creating S3 bucket for Terraform state..."
        aws s3 mb "s3://$BUCKET_NAME" --region "$AWS_REGION"
        aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
        aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }'
        log_success "Terraform state bucket created: $BUCKET_NAME"
    else
        log_info "Terraform state bucket already exists: $BUCKET_NAME"
    fi
}

deploy_infrastructure() {
    log_info "Deploying AWS infrastructure with Terraform..."
    
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    terraform init
    
    # Plan the deployment
    log_info "Planning Terraform deployment..."
    terraform plan -out=tfplan
    
    # Apply the deployment
    log_info "Applying Terraform deployment..."
    terraform apply tfplan
    
    # Get outputs
    log_info "Getting Terraform outputs..."
    terraform output -json > outputs.json
    
    log_success "Infrastructure deployment completed!"
}

build_and_push_backend() {
    log_info "Building and pushing backend Docker image..."
    
    cd "$PROJECT_ROOT/backend"
    
    # Get ECR repository URL from Terraform outputs
    ECR_REPO_URL=$(jq -r '.ecr_repository_url.value' "$TERRAFORM_DIR/outputs.json")
    
    if [ "$ECR_REPO_URL" = "null" ]; then
        log_error "ECR repository URL not found in Terraform outputs"
        exit 1
    fi
    
    # Build Docker image
    log_info "Building Docker image..."
    docker build -f Dockerfile.aws -t rant-zone-backend .
    
    # Tag and push to ECR
    log_info "Tagging and pushing to ECR..."
    docker tag rant-zone-backend:latest "$ECR_REPO_URL:latest"
    aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REPO_URL"
    docker push "$ECR_REPO_URL:latest"
    
    log_success "Backend image pushed to ECR!"
}

deploy_frontend() {
    log_info "Deploying frontend to S3 and CloudFront..."
    
    cd "$PROJECT_ROOT/frontend"
    
    # Build frontend
    log_info "Building frontend..."
    npm install
    npm run build
    
    # Get S3 bucket name from Terraform outputs
    S3_BUCKET=$(jq -r '.s3_bucket_name.value' "$TERRAFORM_DIR/outputs.json")
    
    if [ "$S3_BUCKET" = "null" ]; then
        log_error "S3 bucket name not found in Terraform outputs"
        exit 1
    fi
    
    # Sync to S3
    log_info "Syncing to S3..."
    aws s3 sync .next/static s3://"$S3_BUCKET"/_next/static --cache-control "public, max-age=31536000, immutable"
    aws s3 sync .next/static s3://"$S3_BUCKET"/static --cache-control "public, max-age=31536000, immutable"
    aws s3 sync public s3://"$S3_BUCKET" --cache-control "public, max-age=3600"
    aws s3 sync .next s3://"$S3_BUCKET" --exclude "static/*" --cache-control "public, max-age=0, must-revalidate"
    
    # Invalidate CloudFront cache
    log_info "Invalidating CloudFront cache..."
    CLOUDFRONT_DISTRIBUTION_ID=$(jq -r '.cloudfront_distribution_id.value' "$TERRAFORM_DIR/outputs.json")
    
    if [ "$CLOUDFRONT_DISTRIBUTION_ID" != "null" ]; then
        aws cloudfront create-invalidation --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" --paths "/*"
    fi
    
    log_success "Frontend deployed!"
}

setup_dns() {
    log_info "Setting up DNS records..."
    
    # Get hosted zone ID
    HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$DOMAIN_NAME.'].Id" --output text)
    
    if [ -z "$HOSTED_ZONE_ID" ]; then
        log_error "Hosted zone not found for domain: $DOMAIN_NAME"
        exit 1
    fi
    
    # Get CloudFront distribution domain name
    CLOUDFRONT_DOMAIN=$(jq -r '.cloudfront_distribution_domain_name.value' "$TERRAFORM_DIR/outputs.json")
    ALB_DNS_NAME=$(jq -r '.alb_dns_name.value' "$TERRAFORM_DIR/outputs.json")
    
    # Create DNS records
    log_info "Creating DNS records..."
    
    # Frontend (CloudFront)
    aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch '{
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$DOMAIN_NAME'",
                    "Type": "A",
                    "AliasTarget": {
                        "HostedZoneId": "Z2FDTNDATAQYW2",
                        "DNSName": "'$CLOUDFRONT_DOMAIN'",
                        "EvaluateTargetHealth": false
                    }
                }
            },
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "www.'$DOMAIN_NAME'",
                    "Type": "CNAME",
                    "TTL": 300,
                    "ResourceRecords": [
                        {
                            "Value": "'$CLOUDFRONT_DOMAIN'"
                        }
                    ]
                }
            }
        ]
    }'
    
    # Backend (ALB)
    aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch '{
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "api.'$DOMAIN_NAME'",
                    "Type": "A",
                    "AliasTarget": {
                        "HostedZoneId": "Z35SXDOTRQ7X7K",
                        "DNSName": "'$ALB_DNS_NAME'",
                        "EvaluateTargetHealth": true
                    }
                }
            }
        ]
    }'
    
    log_success "DNS records configured!"
}

run_tests() {
    log_info "Running deployment tests..."
    
    # Test frontend
    log_info "Testing frontend..."
    if curl -f -s "https://$DOMAIN_NAME" > /dev/null; then
        log_success "Frontend is accessible"
    else
        log_warning "Frontend may not be accessible yet (CloudFront propagation)"
    fi
    
    # Test backend
    log_info "Testing backend..."
    if curl -f -s "https://api.$DOMAIN_NAME/health" > /dev/null; then
        log_success "Backend is accessible"
    else
        log_warning "Backend may not be accessible yet (ALB propagation)"
    fi
}

main() {
    log_info "Starting AWS deployment for Rant.Zone..."
    
    # Check prerequisites
    check_aws_cli
    check_terraform
    check_docker
    
    # Setup and deploy
    setup_terraform_backend
    deploy_infrastructure
    build_and_push_backend
    deploy_frontend
    setup_dns
    
    # Wait for propagation
    log_info "Waiting for DNS propagation..."
    sleep 60
    
    # Run tests
    run_tests
    
    log_success "AWS deployment completed successfully!"
    log_info "Your application is now available at:"
    log_info "  Frontend: https://$DOMAIN_NAME"
    log_info "  Backend:  https://api.$DOMAIN_NAME"
}

# Run main function
main "$@" 