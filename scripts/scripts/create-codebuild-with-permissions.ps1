# Create CodeBuild Project with Proper Permissions
Write-Host "🔧 Creating CodeBuild Project with Proper Permissions..." -ForegroundColor Green

Write-Host ""
Write-Host "📋 Step 1: Create Service Role for CodeBuild" -ForegroundColor Yellow
Write-Host "Go to AWS IAM Console: https://console.aws.amazon.com/iam/" -ForegroundColor White
Write-Host "1. Create a new role with these settings:" -ForegroundColor Cyan
Write-Host "   - Trusted entity: AWS service" -ForegroundColor White
Write-Host "   - Service: CodeBuild" -ForegroundColor White
Write-Host "   - Use case: CodeBuild" -ForegroundColor White
Write-Host ""
Write-Host "2. Attach these policies to the role:" -ForegroundColor Cyan
Write-Host "   - AWSCodeBuildDeveloperAccess" -ForegroundColor White
Write-Host "   - AmazonEC2ContainerRegistryPowerUser" -ForegroundColor White
Write-Host "   - AmazonS3FullAccess" -ForegroundColor White
Write-Host "   - CloudWatchLogsFullAccess" -ForegroundColor White

Write-Host ""
Write-Host "📋 Step 2: Create CodeBuild Project" -ForegroundColor Yellow
Write-Host "Go to CodeBuild Console: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor White
Write-Host "1. Click 'Create build project'" -ForegroundColor Cyan
Write-Host "2. Project configuration:" -ForegroundColor Cyan
Write-Host "   - Project name: rant-zone-backend-build" -ForegroundColor White
Write-Host "   - Description: Build and deploy rant-zone backend to ECS" -ForegroundColor White
Write-Host ""
Write-Host "3. Source configuration:" -ForegroundColor Cyan
Write-Host "   - Source provider: GitHub" -ForegroundColor White
Write-Host "   - Repository: Connect using OAuth" -ForegroundColor White
Write-Host "   - Repository: [Your GitHub repo]" -ForegroundColor White
Write-Host "   - Source version: main" -ForegroundColor White
Write-Host "   - Buildspec: Use a buildspec file" -ForegroundColor White
Write-Host "   - Buildspec name: buildspec-optimized.yml" -ForegroundColor White
Write-Host ""
Write-Host "4. Environment configuration:" -ForegroundColor Cyan
Write-Host "   - Environment image: Managed image" -ForegroundColor White
Write-Host "   - Operating system: Amazon Linux 2" -ForegroundColor White
Write-Host "   - Runtime: Standard" -ForegroundColor White
Write-Host "   - Image: aws/codebuild/amazonlinux-x86_64-standard:4.0-22.10.27" -ForegroundColor White
Write-Host "   - Privileged: Check this box (for Docker)" -ForegroundColor White
Write-Host "   - Service role: [Select the role you created in Step 1]" -ForegroundColor White
Write-Host ""
Write-Host "5. Buildspec configuration:" -ForegroundColor Cyan
Write-Host "   - Build commands: Use buildspec file" -ForegroundColor White
Write-Host "   - Buildspec name: buildspec-optimized.yml" -ForegroundColor White
Write-Host ""
Write-Host "6. Artifacts configuration:" -ForegroundColor Cyan
Write-Host "   - Type: Amazon S3" -ForegroundColor White
Write-Host "   - Bucket name: rant-zone-artifacts" -ForegroundColor White
Write-Host "   - Name: rant-zone-backend-build" -ForegroundColor White
Write-Host ""
Write-Host "7. Logs configuration:" -ForegroundColor Cyan
Write-Host "   - CloudWatch logs: Enabled" -ForegroundColor White
Write-Host "   - Group name: /aws/codebuild/rant-zone-backend-build" -ForegroundColor White
Write-Host "   - Stream name: build-log" -ForegroundColor White
Write-Host ""
Write-Host "8. Click 'Create build project'" -ForegroundColor Cyan

Write-Host ""
Write-Host "📋 Step 3: Verify ECR Repository" -ForegroundColor Yellow
Write-Host "Make sure your ECR repository exists:" -ForegroundColor White
Write-Host "aws ecr describe-repositories --repository-names rant-zone-backend --region us-east-1" -ForegroundColor Gray

Write-Host ""
Write-Host "📋 Step 4: Test the Build" -ForegroundColor Yellow
Write-Host "After creating the project, test it with:" -ForegroundColor White
Write-Host "aws codebuild start-build --project-name rant-zone-backend-build --region us-east-1" -ForegroundColor Gray

Write-Host ""
Write-Host "🔍 Common Issues and Solutions:" -ForegroundColor Yellow
Write-Host "1. ECR Login Error: Make sure service role has ECR permissions" -ForegroundColor White
Write-Host "2. S3 Access Error: Make sure service role has S3 permissions" -ForegroundColor White
Write-Host "3. Docker Build Error: Make sure 'Privileged' is checked" -ForegroundColor White
Write-Host "4. GitHub Access Error: Make sure OAuth connection is set up" -ForegroundColor White

Write-Host ""
Write-Host "✅ Ready to create the CodeBuild project!" -ForegroundColor Green
