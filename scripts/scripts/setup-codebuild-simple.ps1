Write-Host "=== CodeBuild Setup Guide ===" -ForegroundColor Green
Write-Host ""

Write-Host "Step 1: Create IAM Service Role" -ForegroundColor Yellow
Write-Host "1. Go to: https://console.aws.amazon.com/iam/" -ForegroundColor White
Write-Host "2. Click 'Roles' then 'Create role'" -ForegroundColor White
Write-Host "3. Select 'AWS service' and 'CodeBuild'" -ForegroundColor White
Write-Host "4. Attach these policies:" -ForegroundColor White
Write-Host "   - AWSCodeBuildDeveloperAccess" -ForegroundColor Cyan
Write-Host "   - AmazonEC2ContainerRegistryPowerUser" -ForegroundColor Cyan
Write-Host "   - AmazonS3FullAccess" -ForegroundColor Cyan
Write-Host "5. Name the role: codebuild-rant-zone-service-role" -ForegroundColor White
Write-Host ""

Write-Host "Step 2: Create CodeBuild Project" -ForegroundColor Yellow
Write-Host "1. Go to: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor White
Write-Host "2. Click 'Create build project'" -ForegroundColor White
Write-Host "3. Project details:" -ForegroundColor White
Write-Host "   - Project name: rant-zone-backend-build" -ForegroundColor Cyan
Write-Host "   - Description: Build rant-zone backend Docker image" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Source:" -ForegroundColor White
Write-Host "   - Source provider: GitHub" -ForegroundColor Cyan
Write-Host "   - Repository: Connect using OAuth" -ForegroundColor Cyan
Write-Host "   - Repository: [Your GitHub repo]" -ForegroundColor Cyan
Write-Host "   - Source version: main" -ForegroundColor Cyan
Write-Host "   - Buildspec: Use a buildspec file" -ForegroundColor Cyan
Write-Host "   - Buildspec name: buildspec-optimized.yml" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Environment:" -ForegroundColor White
Write-Host "   - Environment image: Managed image" -ForegroundColor Cyan
Write-Host "   - Operating system: Amazon Linux 2" -ForegroundColor Cyan
Write-Host "   - Runtime: Standard" -ForegroundColor Cyan
Write-Host "   - Image: aws/codebuild/amazonlinux-x86_64-standard:4.0-22.10.27" -ForegroundColor Cyan
Write-Host "   - Privileged: CHECK THIS BOX" -ForegroundColor Red
Write-Host "   - Service role: [Select the role from Step 1]" -ForegroundColor Cyan
Write-Host ""
Write-Host "6. Buildspec:" -ForegroundColor White
Write-Host "   - Build commands: Use buildspec file" -ForegroundColor Cyan
Write-Host "   - Buildspec name: buildspec-optimized.yml" -ForegroundColor Cyan
Write-Host ""
Write-Host "7. Artifacts:" -ForegroundColor White
Write-Host "   - Type: No artifacts" -ForegroundColor Cyan
Write-Host ""
Write-Host "8. Logs:" -ForegroundColor White
Write-Host "   - CloudWatch logs: Enabled" -ForegroundColor Cyan
Write-Host "   - Group name: /aws/codebuild/rant-zone-backend-build" -ForegroundColor Cyan
Write-Host "   - Stream name: build-log" -ForegroundColor Cyan
Write-Host ""
Write-Host "9. Click 'Create build project'" -ForegroundColor White
Write-Host ""

Write-Host "Step 3: Test the Build" -ForegroundColor Yellow
Write-Host "After creating the project, run:" -ForegroundColor White
Write-Host "aws codebuild start-build --project-name rant-zone-backend-build --region us-east-1" -ForegroundColor Gray
Write-Host ""

Write-Host "=== Key Points ===" -ForegroundColor Green
Write-Host "- Make sure 'Privileged' is checked for Docker builds" -ForegroundColor Red
Write-Host "- Use buildspec-optimized.yml (optimized version with better logging)" -ForegroundColor Yellow
Write-Host "- Service role must have ECR permissions" -ForegroundColor Yellow
Write-Host ""
