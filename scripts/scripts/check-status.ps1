Write-Host "=== Current Status Check ===" -ForegroundColor Green
Write-Host ""

Write-Host "Checking AWS credentials..." -ForegroundColor Yellow
aws sts get-caller-identity

Write-Host ""
Write-Host "Checking ECR repository..." -ForegroundColor Yellow
aws ecr describe-repositories --repository-names rant-zone-backend --region us-east-1 --query 'repositories[0].repositoryUri' --output text

Write-Host ""
Write-Host "Checking CodeBuild projects..." -ForegroundColor Yellow
aws codebuild list-projects --region us-east-1 --output table

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Green
Write-Host "1. Follow the setup guide: .\scripts\setup-codebuild-simple.ps1" -ForegroundColor White
Write-Host "2. Create IAM service role with proper permissions" -ForegroundColor White
Write-Host "3. Create CodeBuild project" -ForegroundColor White
Write-Host "4. Test the build" -ForegroundColor White
Write-Host ""
