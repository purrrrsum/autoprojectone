# Simple Backend Status Check
Write-Host "🔍 Simple Backend Status Check..." -ForegroundColor Green

Write-Host ""
Write-Host "📊 Current Status:" -ForegroundColor Yellow

# Check ECR Images
Write-Host "1. ECR Images:" -ForegroundColor Cyan
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

# Check ECS Services
Write-Host ""
Write-Host "2. ECS Services:" -ForegroundColor Cyan
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

# Check SSM Parameters
Write-Host ""
Write-Host "3. Environment Variables:" -ForegroundColor Cyan
try {
    $result = aws ssm describe-parameters --region us-east-1 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ SSM accessible" -ForegroundColor Green
    } else {
        Write-Host "   ❌ SSM not accessible" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Error checking SSM" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Update IAM permissions if you see ❌ errors" -ForegroundColor Cyan
Write-Host "2. Create CodeBuild project" -ForegroundColor Cyan
Write-Host "3. Build and deploy backend" -ForegroundColor Cyan
Write-Host "4. Create ECS service" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔗 AWS Console Links:" -ForegroundColor Yellow
Write-Host "ECS: https://console.aws.amazon.com/ecs/" -ForegroundColor Cyan
Write-Host "CodeBuild: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor Cyan
Write-Host "ECR: https://console.aws.amazon.com/ecr/" -ForegroundColor Cyan 