# ECS Fargate Deployment Script
Write-Host "🚀 Rant.Zone ECS Fargate Deployment" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

Write-Host ""
Write-Host "📋 Deployment Configuration:" -ForegroundColor Yellow
Write-Host "Environment: Custom Docker image" -ForegroundColor Cyan
Write-Host "Compute: ECS Fargate (serverless containers)" -ForegroundColor Cyan
Write-Host "Running Mode: Container" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔍 Current Status:" -ForegroundColor Yellow

# Check ECR
Write-Host "ECR Repository:" -ForegroundColor Cyan
try {
    $result = aws ecr describe-images --repository-name rant-zone-backend --region us-east-1 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ ECR repository accessible" -ForegroundColor Green
    } else {
        Write-Host "   ❌ ECR repository not accessible" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Error checking ECR" -ForegroundColor Red
}

# Check ECS
Write-Host "ECS Cluster:" -ForegroundColor Cyan
try {
    $result = aws ecs list-services --cluster rant-zone-cluster --region us-east-1 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ ECS cluster accessible" -ForegroundColor Green
    } else {
        Write-Host "   ❌ ECS cluster not accessible" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Error checking ECS" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Update IAM permissions (if needed)" -ForegroundColor Cyan
Write-Host "2. Create CodeBuild project via AWS Console" -ForegroundColor Cyan
Write-Host "3. Build and push Docker image" -ForegroundColor Cyan
Write-Host "4. Create ECS service" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔗 AWS Console Links:" -ForegroundColor Yellow
Write-Host "IAM: https://console.aws.amazon.com/iam/" -ForegroundColor Cyan
Write-Host "CodeBuild: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor Cyan
Write-Host "ECS: https://console.aws.amazon.com/ecs/" -ForegroundColor Cyan
Write-Host "ECR: https://console.aws.amazon.com/ecr/" -ForegroundColor Cyan

Write-Host ""
Write-Host "📝 Manual Steps:" -ForegroundColor Yellow
Write-Host "1. Add CodeBuild permissions to IAM user" -ForegroundColor White
Write-Host "2. Create CodeBuild project in AWS Console" -ForegroundColor White
Write-Host "3. Start build to create Docker image" -ForegroundColor White
Write-Host "4. Create ECS service using task definition" -ForegroundColor White 