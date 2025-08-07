# Build and Deploy Backend using CodeBuild
Write-Host "🚀 Building and Deploying Backend using CodeBuild..." -ForegroundColor Green

# Check if CodeBuild project exists
Write-Host "Checking CodeBuild project..." -ForegroundColor Yellow
try {
    $projectExists = aws codebuild list-projects --region us-east-1 --query "projects[?contains(@, 'rant-zone-backend-build')]" --output text 2>$null
    if (-not $projectExists) {
        Write-Host "❌ CodeBuild project not found. Please create it first:" -ForegroundColor Red
        Write-Host "Run: .\scripts\create-codebuild-project.ps1" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✅ CodeBuild project found: $projectExists" -ForegroundColor Green
} catch {
    Write-Host "❌ Error checking CodeBuild project. Please ensure you have proper permissions." -ForegroundColor Red
    Write-Host "Run: .\scripts\update-iam-permissions.ps1" -ForegroundColor Yellow
    exit 1
}

# Start the build
Write-Host ""
Write-Host "🔨 Starting CodeBuild..." -ForegroundColor Yellow
try {
    $buildResult = aws codebuild start-build --project-name rant-zone-backend-build --region us-east-1
    $buildId = ($buildResult | ConvertFrom-Json).build.id
    Write-Host "✅ Build started with ID: $buildId" -ForegroundColor Green
    Write-Host "🔗 View build logs: https://console.aws.amazon.com/codesuite/codebuild/projects/rant-zone-backend-build/history" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Failed to start build. Please check your permissions and try again." -ForegroundColor Red
    exit 1
}

# Wait for build to complete
Write-Host ""
Write-Host "⏳ Waiting for build to complete..." -ForegroundColor Yellow
Write-Host "This may take 5-10 minutes. You can monitor progress in the AWS Console." -ForegroundColor Cyan

$maxAttempts = 60  # 10 minutes with 10-second intervals
$attempt = 0

while ($attempt -lt $maxAttempts) {
    try {
        $buildStatus = aws codebuild batch-get-builds --ids $buildId --region us-east-1 --query "builds[0].buildStatus" --output text
        Write-Host "Build status: $buildStatus" -ForegroundColor Cyan
        
        if ($buildStatus -eq "SUCCEEDED") {
            Write-Host "✅ Build completed successfully!" -ForegroundColor Green
            break
        } elseif ($buildStatus -eq "FAILED") {
            Write-Host "❌ Build failed. Check the logs for details." -ForegroundColor Red
            Write-Host "🔗 View logs: https://console.aws.amazon.com/codesuite/codebuild/projects/rant-zone-backend-build/history" -ForegroundColor Cyan
            exit 1
        } elseif ($buildStatus -eq "IN_PROGRESS") {
            Write-Host "⏳ Build in progress... ($attempt/$maxAttempts)" -ForegroundColor Yellow
        }
        
        $attempt++
        Start-Sleep -Seconds 10
    } catch {
        Write-Host "❌ Error checking build status. Please check manually." -ForegroundColor Red
        break
    }
}

if ($attempt -ge $maxAttempts) {
    Write-Host "⏰ Build timeout. Please check the AWS Console for current status." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Build process completed!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Check ECR for the new Docker image" -ForegroundColor Cyan
Write-Host "2. Create ECS service: .\scripts\create-ecs-service.ps1" -ForegroundColor Cyan
Write-Host "3. Check backend status: .\scripts\check-backend-status.ps1" -ForegroundColor Cyan 