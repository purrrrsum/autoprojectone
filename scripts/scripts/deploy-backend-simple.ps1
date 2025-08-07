# Simple Backend Deployment Script
Write-Host "🚀 Rant.Zone Backend Deployment" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

Write-Host ""
Write-Host "📋 Deployment Steps:" -ForegroundColor Yellow
Write-Host "1. Fix IAM permissions" -ForegroundColor Cyan
Write-Host "2. Create CodeBuild project" -ForegroundColor Cyan
Write-Host "3. Build and deploy" -ForegroundColor Cyan
Write-Host "4. Create ECS service" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔧 Step 1: IAM Permissions Setup" -ForegroundColor Yellow
Write-Host "You need to add these policies to your IAM user 'rant-zone-deploy':" -ForegroundColor Cyan
Write-Host "- AWSCodeBuildDeveloperAccess" -ForegroundColor White
Write-Host "- IAMFullAccess (temporarily)" -ForegroundColor White
Write-Host "- AmazonS3ReadOnlyAccess" -ForegroundColor White

Write-Host ""
Write-Host "🔗 Go to: https://console.aws.amazon.com/iam/" -ForegroundColor Cyan
Write-Host "Find user: rant-zone-deploy" -ForegroundColor White
Write-Host "Add the policies above" -ForegroundColor White

Write-Host ""
$continue = Read-Host "After adding IAM permissions, press Enter to continue..."

Write-Host ""
Write-Host "🔧 Step 2: Create CodeBuild Project" -ForegroundColor Yellow
Write-Host "Go to: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor Cyan
Write-Host "Create build project with these settings:" -ForegroundColor White
Write-Host "- Project name: rant-zone-backend-build" -ForegroundColor Cyan
Write-Host "- Source: GitHub (connect your repository)" -ForegroundColor Cyan
Write-Host "- Environment: aws/codebuild/amazonlinux-x86_64-standard:4.0-22.10.27" -ForegroundColor Cyan
Write-Host "- Buildspec: buildspec-optimized.yml" -ForegroundColor Cyan

Write-Host ""
$continue = Read-Host "After creating CodeBuild project, press Enter to continue..."

Write-Host ""
Write-Host "🔨 Step 3: Build and Deploy" -ForegroundColor Yellow
Write-Host "Starting CodeBuild..." -ForegroundColor Cyan

try {
    $buildResult = aws codebuild start-build --project-name rant-zone-backend-build --region us-east-1
    if ($LASTEXITCODE -eq 0) {
        $buildId = ($buildResult | ConvertFrom-Json).build.id
        Write-Host "✅ Build started with ID: $buildId" -ForegroundColor Green
        Write-Host "🔗 View logs: https://console.aws.amazon.com/codesuite/codebuild/projects/rant-zone-backend-build/history" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Failed to start build" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error starting build" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔧 Step 4: Create ECS Service" -ForegroundColor Yellow
Write-Host "Go to: https://console.aws.amazon.com/ecs/" -ForegroundColor Cyan
Write-Host "Create service with these settings:" -ForegroundColor White
Write-Host "- Cluster: rant-zone-cluster" -ForegroundColor Cyan
Write-Host "- Task Definition: rant-zone-backend" -ForegroundColor Cyan
Write-Host "- Service name: rant-zone-backend-service" -ForegroundColor Cyan
Write-Host "- Launch type: FARGATE" -ForegroundColor Cyan

Write-Host ""
Write-Host "🎉 Deployment completed!" -ForegroundColor Green
Write-Host ""
Write-Host "🔗 Useful links:" -ForegroundColor Yellow
Write-Host "ECS Console: https://console.aws.amazon.com/ecs/" -ForegroundColor Cyan
Write-Host "CodeBuild Console: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor Cyan
Write-Host "ECR Console: https://console.aws.amazon.com/ecr/" -ForegroundColor Cyan 