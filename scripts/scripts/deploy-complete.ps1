# Complete Deployment Script for Project WebApp
Write-Host "=== Project WebApp Complete Deployment ===" -ForegroundColor Green
Write-Host ""

# Check if AWS CLI is installed and configured
Write-Host "Step 1: Checking AWS CLI configuration..." -ForegroundColor Yellow
try {
    $awsIdentity = aws sts get-caller-identity 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ AWS CLI is configured" -ForegroundColor Green
        Write-Host "Account: $($awsIdentity.Account)" -ForegroundColor Cyan
        Write-Host "User: $($awsIdentity.Arn)" -ForegroundColor Cyan
    } else {
        Write-Host "❌ AWS CLI not configured. Please run 'aws configure' first." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ AWS CLI not found. Please install AWS CLI first." -ForegroundColor Red
    exit 1
}

# Check if Docker is running
Write-Host ""
Write-Host "Step 2: Checking Docker..." -ForegroundColor Yellow
try {
    docker version 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker is running" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Docker not found. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check ECR repository
Write-Host ""
Write-Host "Step 3: Checking ECR repository..." -ForegroundColor Yellow
$ecrRepo = aws ecr describe-repositories --repository-names rant-zone-backend --region us-east-1 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ ECR repository exists" -ForegroundColor Green
} else {
    Write-Host "❌ ECR repository not found. Creating..." -ForegroundColor Yellow
    aws ecr create-repository --repository-name rant-zone-backend --region us-east-1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ECR repository created" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create ECR repository" -ForegroundColor Red
        exit 1
    }
}

# Check CodeBuild project
Write-Host ""
Write-Host "Step 4: Checking CodeBuild project..." -ForegroundColor Yellow
$codebuildProjects = aws codebuild list-projects --region us-east-1 --query 'projects' --output text 2>$null
if ($codebuildProjects -contains "rant-zone-backend-build") {
    Write-Host "✅ CodeBuild project exists" -ForegroundColor Green
} else {
    Write-Host "❌ CodeBuild project not found. Please create it first:" -ForegroundColor Red
    Write-Host "   Run: .\scripts\setup-codebuild-simple.ps1" -ForegroundColor Cyan
    exit 1
}

# Build and push Docker image
Write-Host ""
Write-Host "Step 5: Building and pushing Docker image..." -ForegroundColor Yellow
Write-Host "Starting CodeBuild project..." -ForegroundColor Cyan
$buildResult = aws codebuild start-build --project-name rant-zone-backend-build --region us-east-1 --query 'build.id' --output text
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build started with ID: $buildResult" -ForegroundColor Green
    Write-Host "Monitor build at: https://console.aws.amazon.com/codesuite/codebuild/projects/rant-zone-backend-build/history" -ForegroundColor Cyan
} else {
    Write-Host "❌ Failed to start build" -ForegroundColor Red
    exit 1
}

# Wait for build to complete
Write-Host ""
Write-Host "Step 6: Waiting for build to complete..." -ForegroundColor Yellow
$maxAttempts = 60
$attempt = 0
do {
    Start-Sleep -Seconds 30
    $attempt++
    $buildStatus = aws codebuild batch-get-builds --ids $buildResult --region us-east-1 --query 'builds[0].buildStatus' --output text 2>$null
    
    Write-Host "Build status: $buildStatus (Attempt $attempt/$maxAttempts)" -ForegroundColor Cyan
    
    if ($buildStatus -eq "SUCCEEDED") {
        Write-Host "✅ Build completed successfully!" -ForegroundColor Green
        break
    } elseif ($buildStatus -eq "FAILED" -or $buildStatus -eq "FAULT" -or $buildStatus -eq "STOPPED") {
        Write-Host "❌ Build failed with status: $buildStatus" -ForegroundColor Red
        exit 1
    }
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "❌ Build timeout. Check the build logs manually." -ForegroundColor Red
    exit 1
}

# Check ECS service
Write-Host ""
Write-Host "Step 7: Checking ECS service..." -ForegroundColor Yellow
$ecsServices = aws ecs list-services --cluster default --region us-east-1 --query 'serviceArns' --output text 2>$null
if ($ecsServices -contains "rant-zone-backend-service") {
    Write-Host "✅ ECS service exists" -ForegroundColor Green
    
    # Update service
    Write-Host "Updating ECS service..." -ForegroundColor Cyan
    aws ecs update-service --cluster default --service rant-zone-backend-service --force-new-deployment --region us-east-1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ECS service updated" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to update ECS service" -ForegroundColor Red
    }
} else {
    Write-Host "❌ ECS service not found. Please create it first:" -ForegroundColor Red
    Write-Host "   Run: .\scripts\create-ecs-service.ps1" -ForegroundColor Cyan
}

# Check frontend deployment
Write-Host ""
Write-Host "Step 8: Checking frontend deployment..." -ForegroundColor Yellow
Write-Host "To deploy frontend, run: .\scripts\deploy-frontend-simple.ps1" -ForegroundColor Cyan

# Final status
Write-Host ""
Write-Host "=== Deployment Summary ===" -ForegroundColor Green
Write-Host "✅ Backend Docker image built and pushed to ECR" -ForegroundColor Green
Write-Host "✅ ECS service updated (if exists)" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Deploy frontend: .\scripts\deploy-frontend-simple.ps1" -ForegroundColor Cyan
Write-Host "2. Check ECS service status: .\scripts\check-backend-status.ps1" -ForegroundColor Cyan
Write-Host "3. Monitor logs: https://console.aws.amazon.com/cloudwatch/home" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎉 Deployment process completed!" -ForegroundColor Green
