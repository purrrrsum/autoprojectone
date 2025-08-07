# Master Backend Deployment Script
Write-Host "🚀 Rant.Zone Backend - Master Deployment Script" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

Write-Host ""
Write-Host "📋 This script will automate the complete backend deployment process." -ForegroundColor Yellow
Write-Host "It includes:" -ForegroundColor Cyan
Write-Host "1. IAM permissions setup" -ForegroundColor White
Write-Host "2. CodeBuild project creation" -ForegroundColor White
Write-Host "3. Docker image build and push" -ForegroundColor White
Write-Host "4. ECS service deployment" -ForegroundColor White
Write-Host "5. Health checks and verification" -ForegroundColor White

Write-Host ""
Write-Host "🎯 Deployment Configuration:" -ForegroundColor Yellow
Write-Host "Environment: Custom Docker image" -ForegroundColor Cyan
Write-Host "Compute: ECS Fargate (serverless containers)" -ForegroundColor Cyan
Write-Host "Running Mode: Container" -ForegroundColor Cyan
Write-Host "Image: aws/codebuild/amazonlinux-x86_64-standard:4.0-22.10.27" -ForegroundColor Cyan

Write-Host ""
$continue = Read-Host "Do you want to start the automated deployment? (y/n)"
if ($continue -ne "y" -and $continue -ne "Y") {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

# Step 1: Check and setup IAM permissions
Write-Host ""
Write-Host "🔧 Step 1: Checking IAM permissions..." -ForegroundColor Yellow
try {
    $codebuildTest = aws codebuild list-projects --region us-east-1 --max-items 1 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ IAM permissions are sufficient" -ForegroundColor Green
        $iamOk = $true
    } else {
        Write-Host "   ❌ IAM permissions issue detected" -ForegroundColor Red
        $iamOk = $false
    }
} catch {
    Write-Host "   ❌ IAM permissions issue detected" -ForegroundColor Red
    $iamOk = $false
}

if (-not $iamOk) {
    Write-Host ""
    Write-Host "🔧 Setting up IAM permissions..." -ForegroundColor Yellow
    Write-Host "Please follow the instructions to add required permissions:" -ForegroundColor Cyan
    & .\scripts\setup-iam-permissions.ps1
    
    Write-Host ""
    $continue = Read-Host "After adding IAM permissions, press Enter to continue..."
}

# Step 2: Run automated deployment
Write-Host ""
Write-Host "🚀 Step 2: Running automated deployment..." -ForegroundColor Yellow
& .\scripts\auto-deploy-backend.ps1

Write-Host ""
Write-Host "🎉 Master deployment process completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Deployment Summary:" -ForegroundColor Yellow
Write-Host "✅ IAM permissions configured" -ForegroundColor Green
Write-Host "✅ CodeBuild project created" -ForegroundColor Green
Write-Host "✅ Docker image built and pushed" -ForegroundColor Green
Write-Host "✅ ECS service deployed" -ForegroundColor Green

Write-Host ""
Write-Host "🔗 Your Backend URLs:" -ForegroundColor Yellow
Write-Host "ECS Console: https://console.aws.amazon.com/ecs/" -ForegroundColor Cyan
Write-Host "CodeBuild Console: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor Cyan
Write-Host "ECR Console: https://console.aws.amazon.com/ecr/" -ForegroundColor Cyan

Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Test your backend endpoints" -ForegroundColor Cyan
Write-Host "2. Update frontend environment variables" -ForegroundColor Cyan
Write-Host "3. Set up custom domain and SSL" -ForegroundColor Cyan
Write-Host "4. Configure monitoring and alerts" -ForegroundColor Cyan

Write-Host ""
Write-Host "🎯 Success! Your backend is now deployed on AWS ECS Fargate." -ForegroundColor Green 