#!/bin/bash

# Simplified AWS Deployment Script for Rant.Zone
# This script doesn't require jq and uses basic shell commands

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

# Simple JSON parsing function (no jq required)
get_json_value() {
    local json_file="$1"
    local key="$2"
    
    # Use grep and sed to extract values (basic parsing)
    if [[ "$key" == "aws.region" ]]; then
        grep -o '"region"[[:space:]]*:[[:space:]]*"[^"]*"' "$json_file" | sed 's/.*"region"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
    elif [[ "$key" == "aws.account_id" ]]; then
        grep -o '"account_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$json_file" | sed 's/.*"account_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
    elif [[ "$key" == "networking.route53.domain_name" ]]; then
        grep -o '"domain_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$json_file" | sed 's/.*"domain_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
    else
        echo ""
    fi
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
    
    # Get outputs (simplified)
    log_info "Getting Terraform outputs..."
    terraform output > outputs.txt
    
    log_success "Infrastructure deployment completed!"
}

build_and_push_backend() {
    log_info "Building and pushing backend Docker image..."
    
    cd "$PROJECT_ROOT/backend"
    
    # Get ECR repository URL from Terraform outputs (simplified)
    ECR_REPO_URL=$(grep "ecr_repository_url" "$TERRAFORM_DIR/outputs.txt" | sed 's/.*"\([^"]*\)".*/\1/')
    
    if [ -z "$ECR_REPO_URL" ]; then
        log_error "ECR repository URL not found in Terraform outputs"
        log_info "Please check the Terraform outputs manually:"
        cat "$TERRAFORM_DIR/outputs.txt"
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
    
    # Get S3 bucket name from Terraform outputs (simplified)
    S3_BUCKET=$(grep "s3_bucket_name" "$TERRAFORM_DIR/outputs.txt" | sed 's/.*"\([^"]*\)".*/\1/')
    
    if [ -z "$S3_BUCKET" ]; then
        log_error "S3 bucket name not found in Terraform outputs"
        log_info "Please check the Terraform outputs manually:"
        cat "$TERRAFORM_DIR/outputs.txt"
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
    CLOUDFRONT_DISTRIBUTION_ID=$(grep "cloudfront_distribution_id" "$TERRAFORM_DIR/outputs.txt" | sed 's/.*"\([^"]*\)".*/\1/')
    
    if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
        aws cloudfront create-invalidation --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" --paths "/*"
    else
        log_warning "CloudFront distribution ID not found, skipping cache invalidation"
    fi
    
    log_success "Frontend deployed!"
}

setup_dns() {
    log_info "Setting up DNS records..."
    
    # Get hosted zone ID
    HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$DOMAIN_NAME.'].Id" --output text | sed 's/\/hostedzone\///')
    
    if [ -z "$HOSTED_ZONE_ID" ]; then
        log_error "Hosted zone not found for domain: $DOMAIN_NAME"
        exit 1
    fi
    
    # Get CloudFront distribution domain name
    CLOUDFRONT_DOMAIN=$(grep "cloudfront_distribution_domain_name" "$TERRAFORM_DIR/outputs.txt" | sed 's/.*"\([^"]*\)".*/\1/')
    ALB_DNS_NAME=$(grep "alb_dns_name" "$TERRAFORM_DIR/outputs.txt" | sed 's/.*"\([^"]*\)".*/\1/')
    
    if [ -z "$CLOUDFRONT_DOMAIN" ] || [ -z "$ALB_DNS_NAME" ]; then
        log_error "CloudFront or ALB DNS names not found in Terraform outputs"
        log_info "Please check the Terraform outputs manually:"
        cat "$TERRAFORM_DIR/outputs.txt"
        exit 1
    fi
    
    # Create DNS records
    log_info "Creating DNS records..."
    
    # Frontend (CloudFront) - A record
    aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch "{
        \"Changes\": [
            {
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"$DOMAIN_NAME\",
                    \"Type\": \"A\",
                    \"AliasTarget\": {
                        \"HostedZoneId\": \"Z2FDTNDATAQYW2\",
                        \"DNSName\": \"$CLOUDFRONT_DOMAIN\",
                        \"EvaluateTargetHealth\": false
                    }
                }
            }
        ]
    }"
    
    # Backend (ALB) - A record
    aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch "{
        \"Changes\": [
            {
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"api.$DOMAIN_NAME\",
                    \"Type\": \"A\",
                    \"AliasTarget\": {
                        \"HostedZoneId\": \"Z35SXDOTRQ7X7K\",
                        \"DNSName\": \"$ALB_DNS_NAME\",
                        \"EvaluateTargetHealth\": true
                    }
                }
            }
        ]
    }"
    
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
    log_info "Starting AWS deployment for Rant.Zone (Simplified version)..."
    
    # Check prerequisites
    check_aws_cli
    check_terraform
    check_docker
    
    # Load configuration (simplified)
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "AWS configuration file not found at $CONFIG_FILE"
        exit 1
    fi
    
    # Parse configuration (simplified)
    AWS_REGION=$(get_json_value "$CONFIG_FILE" "aws.region")
    AWS_ACCOUNT_ID=$(get_json_value "$CONFIG_FILE" "aws.account_id")
    DOMAIN_NAME=$(get_json_value "$CONFIG_FILE" "networking.route53.domain_name")
    
    if [ -z "$AWS_REGION" ] || [ -z "$AWS_ACCOUNT_ID" ] || [ -z "$DOMAIN_NAME" ]; then
        log_error "Failed to parse configuration. Please check your aws-config.json file."
        exit 1
    fi
    
    log_info "Using configuration:"
    log_info "  AWS Region: $AWS_REGION"
    log_info "  AWS Account ID: $AWS_ACCOUNT_ID"
    log_info "  Domain: $DOMAIN_NAME"
    
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
    log_info ""
    log_info "Note: DNS propagation may take up to 24-48 hours to complete globally."
}

# Run main function
main "$@" 