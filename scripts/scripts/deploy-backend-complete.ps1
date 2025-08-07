# Complete Backend Deployment Script
Write-Host "🚀 Rant.Zone Backend Deployment - Complete Process" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

Write-Host ""
Write-Host "📋 This script will guide you through the complete backend deployment process." -ForegroundColor Yellow
Write-Host "It includes:" -ForegroundColor Cyan
Write-Host "1. Checking current status" -ForegroundColor White
Write-Host "2. Updating IAM permissions (if needed)" -ForegroundColor White
Write-Host "3. Creating CodeBuild project (if needed)" -ForegroundColor White
Write-Host "4. Building and deploying Docker image" -ForegroundColor White
Write-Host "5. Creating ECS service (if needed)" -ForegroundColor White
Write-Host "6. Final status check" -ForegroundColor White

Write-Host ""
$continue = Read-Host "Do you want to continue? (y/n)"
if ($continue -ne "y" -and $continue -ne "Y") {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🔍 Step 1: Checking current status..." -ForegroundColor Yellow
& .\scripts\check-backend-status.ps1

Write-Host ""
Write-Host "🔧 Step 2: Checking IAM permissions..." -ForegroundColor Yellow
& .\scripts\update-iam-permissions.ps1

Write-Host ""
Write-Host "📋 Step 3: Creating CodeBuild project (if needed)..." -ForegroundColor Yellow
Write-Host "Please follow the manual steps shown above to create the CodeBuild project." -ForegroundColor Cyan
Write-Host "After creating the project, press Enter to continue..." -ForegroundColor White
Read-Host

Write-Host ""
Write-Host "🔨 Step 4: Building and deploying Docker image..." -ForegroundColor Yellow
& .\scripts\build-and-deploy-backend.ps1

Write-Host ""
Write-Host "📋 Step 5: Creating ECS service (if needed)..." -ForegroundColor Yellow
Write-Host "Please follow the manual steps shown above to create the ECS service." -ForegroundColor Cyan
Write-Host "After creating the service, press Enter to continue..." -ForegroundColor White
Read-Host

Write-Host ""
Write-Host "🔍 Step 6: Final status check..." -ForegroundColor Yellow
& .\scripts\check-backend-status.ps1

Write-Host ""
Write-Host "🎉 Backend deployment process completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Test your backend endpoints" -ForegroundColor Cyan
Write-Host "2. Update frontend environment variables" -ForegroundColor Cyan
Write-Host "3. Set up custom domain and SSL" -ForegroundColor Cyan
Write-Host "4. Configure monitoring and alerts" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔗 Useful resources:" -ForegroundColor Yellow
Write-Host "- AWS ECS Console: https://console.aws.amazon.com/ecs/" -ForegroundColor Cyan
Write-Host "- AWS CodeBuild Console: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor Cyan
Write-Host "- AWS ECR Console: https://console.aws.amazon.com/ecr/" -ForegroundColor Cyan
Write-Host "- Project Documentation: README.md" -ForegroundColor Cyan 