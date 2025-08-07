# Create CodeBuild Project for Backend Deployment
Write-Host "🚀 Creating CodeBuild Project for Backend Deployment..." -ForegroundColor Green

# Check if CodeBuild project already exists
Write-Host "Checking if CodeBuild project exists..." -ForegroundColor Yellow
try {
    $existingProject = aws codebuild list-projects --region us-east-1 --query "projects[?contains(@, 'rant-zone-backend-build')]" --output text 2>$null
    if ($existingProject) {
        Write-Host "✅ CodeBuild project already exists: $existingProject" -ForegroundColor Green
        Write-Host "You can skip this step and proceed to build the project." -ForegroundColor Cyan
        exit 0
    }
} catch {
    Write-Host "No existing project found, creating new one..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Manual Steps to Create CodeBuild Project:" -ForegroundColor Yellow
Write-Host "1. Go to AWS CodeBuild Console: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor White
Write-Host "2. Click 'Create build project'" -ForegroundColor White
Write-Host "3. Configure project settings:" -ForegroundColor White
Write-Host "   - Project name: rant-zone-backend-build" -ForegroundColor Cyan
Write-Host "   - Source provider: GitHub" -ForegroundColor Cyan
Write-Host "   - Repository: Connect using OAuth" -ForegroundColor Cyan
Write-Host "   - Repository URL: https://github.com/purrrrsum/autoprojectone" -ForegroundColor Cyan
Write-Host "   - Source version: main" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Environment configuration:" -ForegroundColor White
Write-Host "   - Environment image: Managed image" -ForegroundColor Cyan
Write-Host "   - Operating system: Ubuntu" -ForegroundColor Cyan
Write-Host "   - Runtime: Standard" -ForegroundColor Cyan
Write-Host "   - Image: aws/codebuild/amazonlinux2-x86_64-standard:4.0" -ForegroundColor Cyan
Write-Host "   - Compute resources: Use this build project's compute resources" -ForegroundColor Cyan
Write-Host "   - Service role: New service role" -ForegroundColor Cyan
Write-Host "   - Role name: codebuild-rant-zone-backend-build-service-role" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Buildspec configuration:" -ForegroundColor White
Write-Host "   - Buildspec name: buildspec.yml" -ForegroundColor Cyan
Write-Host "   - Use a buildspec file: Yes" -ForegroundColor Cyan
Write-Host ""
Write-Host "6. Artifacts:" -ForegroundColor White
Write-Host "   - Type: No artifacts" -ForegroundColor Cyan
Write-Host ""
Write-Host "7. Logs:" -ForegroundColor White
Write-Host "   - CloudWatch logs: Enabled" -ForegroundColor Cyan
Write-Host "   - Group name: /aws/codebuild/rant-zone-backend-build" -ForegroundColor Cyan
Write-Host "   - Stream name: build-log" -ForegroundColor Cyan
Write-Host ""
Write-Host "8. Click 'Create build project'" -ForegroundColor White

Write-Host ""
Write-Host "✅ After creating the project, run: .\scripts\build-and-deploy-backend.ps1" -ForegroundColor Green 