Write-Host "=== CodeBuild Test Script ===" -ForegroundColor Green
Write-Host ""

Write-Host "Checking if CodeBuild project exists..." -ForegroundColor Yellow
$projects = aws codebuild list-projects --region us-east-1 --query 'projects' --output text

if ($projects -contains "rant-zone-backend-build") {
    Write-Host "✅ CodeBuild project 'rant-zone-backend-build' found!" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Starting build..." -ForegroundColor Yellow
    $buildResult = aws codebuild start-build --project-name rant-zone-backend-build --region us-east-1 --query 'build.id' --output text
    
    Write-Host "Build started with ID: $buildResult" -ForegroundColor Green
    Write-Host ""
    Write-Host "To monitor the build, go to:" -ForegroundColor Yellow
    Write-Host "https://console.aws.amazon.com/codesuite/codebuild/projects/rant-zone-backend-build/history" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "Or check build status with:" -ForegroundColor Yellow
    Write-Host "aws codebuild batch-get-builds --ids $buildResult --region us-east-1" -ForegroundColor Gray
} else {
    Write-Host "❌ CodeBuild project 'rant-zone-backend-build' not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available projects:" -ForegroundColor Yellow
    aws codebuild list-projects --region us-east-1 --output table
    Write-Host ""
    Write-Host "Please create the CodeBuild project first using:" -ForegroundColor Yellow
    Write-Host ".\scripts\setup-codebuild-simple.ps1" -ForegroundColor Cyan
}

Write-Host ""
