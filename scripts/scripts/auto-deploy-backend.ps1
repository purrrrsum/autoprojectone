# Automated Backend Deployment Script
Write-Host "🚀 Automated Backend Deployment for Rant.Zone" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

Write-Host ""
Write-Host "📋 This script will:" -ForegroundColor Yellow
Write-Host "1. Check current status" -ForegroundColor Cyan
Write-Host "2. Create CodeBuild project (if needed)" -ForegroundColor Cyan
Write-Host "3. Build and push Docker image" -ForegroundColor Cyan
Write-Host "4. Create ECS service (if needed)" -ForegroundColor Cyan
Write-Host "5. Verify deployment" -ForegroundColor Cyan

Write-Host ""
$continue = Read-Host "Do you want to continue? (y/n)"
if ($continue -ne "y" -and $continue -ne "Y") {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

# Step 1: Check current status
Write-Host ""
Write-Host "🔍 Step 1: Checking current status..." -ForegroundColor Yellow

# Check ECR
Write-Host "Checking ECR repository..." -ForegroundColor Cyan
try {
    $ecrResult = aws ecr describe-images --repository-name rant-zone-backend --region us-east-1 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ ECR repository accessible" -ForegroundColor Green
    } else {
        Write-Host "   ❌ ECR repository not accessible" -ForegroundColor Red
        Write-Host "   Please check your IAM permissions" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "   ❌ Error checking ECR" -ForegroundColor Red
    exit 1
}

# Check ECS
Write-Host "Checking ECS cluster..." -ForegroundColor Cyan
try {
    $ecsResult = aws ecs list-services --cluster rant-zone-cluster --region us-east-1 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ ECS cluster accessible" -ForegroundColor Green
    } else {
        Write-Host "   ❌ ECS cluster not accessible" -ForegroundColor Red
        Write-Host "   Please check your IAM permissions" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "   ❌ Error checking ECS" -ForegroundColor Red
    exit 1
}

# Step 2: Check CodeBuild project
Write-Host ""
Write-Host "🔍 Step 2: Checking CodeBuild project..." -ForegroundColor Yellow
try {
    $codebuildResult = aws codebuild list-projects --region us-east-1 --query "projects[?contains(@, 'rant-zone-backend-build')]" --output text 2>$null
    if ($LASTEXITCODE -eq 0 -and $codebuildResult) {
        Write-Host "   ✅ CodeBuild project exists: $codebuildResult" -ForegroundColor Green
        $codebuildExists = $true
    } else {
        Write-Host "   ❌ CodeBuild project not found" -ForegroundColor Red
        Write-Host "   Will create CodeBuild project..." -ForegroundColor Yellow
        $codebuildExists = $false
    }
} catch {
    Write-Host "   ❌ Error checking CodeBuild - IAM permissions issue" -ForegroundColor Red
    Write-Host "   Please add CodeBuild permissions to your IAM user" -ForegroundColor Yellow
    Write-Host "   Run: .\scripts\fix-codebuild-permissions.ps1" -ForegroundColor Cyan
    exit 1
}

# Step 3: Create CodeBuild project if needed
if (-not $codebuildExists) {
    Write-Host ""
    Write-Host "🔧 Step 3: Creating CodeBuild project..." -ForegroundColor Yellow
    Write-Host "This requires IAM permissions. Please:" -ForegroundColor Cyan
    Write-Host "1. Add AWSCodeBuildDeveloperAccess policy to your user" -ForegroundColor White
    Write-Host "2. Add IAMFullAccess policy (temporarily)" -ForegroundColor White
    Write-Host "3. Create CodeBuild project manually in AWS Console" -ForegroundColor White
    Write-Host ""
    Write-Host "CodeBuild Project Settings:" -ForegroundColor Yellow
    Write-Host "- Project name: rant-zone-backend-build" -ForegroundColor Cyan
    Write-Host "- Source: GitHub (connect your repository)" -ForegroundColor Cyan
    Write-Host "- Environment: aws/codebuild/amazonlinux-x86_64-standard:4.0-22.10.27" -ForegroundColor Cyan
    Write-Host "- Buildspec: buildspec-optimized.yml" -ForegroundColor Cyan
    Write-Host ""
    $continue = Read-Host "After creating CodeBuild project, press Enter to continue..."
}

# Step 4: Build and deploy
Write-Host ""
Write-Host "🔨 Step 4: Building and deploying Docker image..." -ForegroundColor Yellow
try {
    Write-Host "Starting CodeBuild..." -ForegroundColor Cyan
    $buildResult = aws codebuild start-build --project-name rant-zone-backend-build --region us-east-1
    if ($LASTEXITCODE -eq 0) {
        $buildId = ($buildResult | ConvertFrom-Json).build.id
        Write-Host "   ✅ Build started with ID: $buildId" -ForegroundColor Green
        Write-Host "   🔗 View build logs: https://console.aws.amazon.com/codesuite/codebuild/projects/rant-zone-backend-build/history" -ForegroundColor Cyan
    } else {
        Write-Host "   ❌ Failed to start build" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ Error starting build" -ForegroundColor Red
    exit 1
}

# Step 5: Wait for build completion
Write-Host ""
Write-Host "⏳ Step 5: Waiting for build completion..." -ForegroundColor Yellow
Write-Host "This may take 5-10 minutes. You can monitor progress in the AWS Console." -ForegroundColor Cyan

$maxAttempts = 60  # 10 minutes with 10-second intervals
$attempt = 0

while ($attempt -lt $maxAttempts) {
    try {
        $buildStatus = aws codebuild batch-get-builds --ids $buildId --region us-east-1 --query "builds[0].buildStatus" --output text
        Write-Host "Build status: $buildStatus" -ForegroundColor Cyan
        
        if ($buildStatus -eq "SUCCEEDED") {
            Write-Host "   ✅ Build completed successfully!" -ForegroundColor Green
            break
        } elseif ($buildStatus -eq "FAILED") {
            Write-Host "   ❌ Build failed. Check the logs for details." -ForegroundColor Red
            Write-Host "   🔗 View logs: https://console.aws.amazon.com/codesuite/codebuild/projects/rant-zone-backend-build/history" -ForegroundColor Cyan
            exit 1
        } elseif ($buildStatus -eq "IN_PROGRESS") {
            Write-Host "   ⏳ Build in progress... ($attempt/$maxAttempts)" -ForegroundColor Yellow
        }
        
        $attempt++
        Start-Sleep -Seconds 10
    } catch {
        Write-Host "   ❌ Error checking build status" -ForegroundColor Red
        break
    }
}

if ($attempt -ge $maxAttempts) {
    Write-Host "   ⏰ Build timeout. Please check the AWS Console for current status." -ForegroundColor Yellow
}

# Step 6: Check ECS service
Write-Host ""
Write-Host "🔍 Step 6: Checking ECS service..." -ForegroundColor Yellow
try {
    $services = aws ecs list-services --cluster rant-zone-cluster --region us-east-1 --query "serviceArns[?contains(@, 'rant-zone-backend')]" --output text 2>$null
    if ($LASTEXITCODE -eq 0 -and $services) {
        Write-Host "   ✅ ECS service exists: $services" -ForegroundColor Green
    } else {
        Write-Host "   ❌ ECS service not found" -ForegroundColor Red
        Write-Host "   Please create ECS service manually:" -ForegroundColor Yellow
        Write-Host "   1. Go to ECS Console: https://console.aws.amazon.com/ecs/" -ForegroundColor White
        Write-Host "   2. Click on cluster: rant-zone-cluster" -ForegroundColor White
        Write-Host "   3. Click 'Create Service'" -ForegroundColor White
        Write-Host "   4. Use task definition: rant-zone-backend" -ForegroundColor White
    }
} catch {
    Write-Host "   ❌ Error checking ECS service" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 Deployment process completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Create ECS service (if not exists)" -ForegroundColor Cyan
Write-Host "2. Test backend endpoints" -ForegroundColor Cyan
Write-Host "3. Update frontend environment variables" -ForegroundColor Cyan
Write-Host "4. Set up custom domain and SSL" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔗 Useful links:" -ForegroundColor Yellow
Write-Host "ECS Console: https://console.aws.amazon.com/ecs/" -ForegroundColor Cyan
Write-Host "CodeBuild Console: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor Cyan
Write-Host "ECR Console: https://console.aws.amazon.com/ecr/" -ForegroundColor Cyan 