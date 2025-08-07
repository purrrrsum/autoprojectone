# Setup IAM Permissions for Backend Deployment
Write-Host "🔧 Setting up IAM Permissions for Backend Deployment" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

Write-Host ""
Write-Host "❌ Current Issue: Missing IAM permissions for CodeBuild" -ForegroundColor Red
Write-Host "Error: iam:CreateRole permission required" -ForegroundColor Red

Write-Host ""
Write-Host "🔧 Solution: Add required policies to your IAM user" -ForegroundColor Yellow

Write-Host ""
Write-Host "📋 Manual Steps Required:" -ForegroundColor Yellow
Write-Host "1. Go to AWS IAM Console: https://console.aws.amazon.com/iam/" -ForegroundColor White
Write-Host "2. Find user: rant-zone-deploy" -ForegroundColor White
Write-Host "3. Click on the user and go to 'Permissions' tab" -ForegroundColor White
Write-Host "4. Click 'Add permissions'" -ForegroundColor White
Write-Host "5. Choose 'Attach policies directly'" -ForegroundColor White
Write-Host "6. Add these policies:" -ForegroundColor White
Write-Host "   - AWSCodeBuildDeveloperAccess" -ForegroundColor Cyan
Write-Host "   - IAMFullAccess (temporarily)" -ForegroundColor Cyan
Write-Host "   - AmazonS3ReadOnlyAccess" -ForegroundColor Cyan

Write-Host ""
Write-Host "📝 Alternative: Create Custom Policy (More Secure)" -ForegroundColor Yellow
Write-Host "Create this JSON policy in IAM Console:" -ForegroundColor White
Write-Host @"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:*",
                "logs:*",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:PutRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:PassRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "ecr:*",
                "ecs:*",
                "s3:*",
                "ssm:*"
            ],
            "Resource": "*"
        }
    ]
}
"@ -ForegroundColor Gray

Write-Host ""
Write-Host "🎯 After adding permissions:" -ForegroundColor Yellow
Write-Host "1. Run: .\scripts\auto-deploy-backend.ps1" -ForegroundColor Cyan
Write-Host "2. The script will handle the rest automatically" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔗 AWS Console Links:" -ForegroundColor Yellow
Write-Host "IAM Console: https://console.aws.amazon.com/iam/" -ForegroundColor Cyan
Write-Host "CodeBuild Console: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor Cyan
Write-Host "ECS Console: https://console.aws.amazon.com/ecs/" -ForegroundColor Cyan

Write-Host ""
Write-Host "⚠️  Security Note:" -ForegroundColor Yellow
Write-Host "After deployment is complete, consider removing IAMFullAccess" -ForegroundColor White
Write-Host "and using a more restrictive custom policy for ongoing operations." -ForegroundColor White 