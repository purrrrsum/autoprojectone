# Update IAM Permissions for Backend Deployment
Write-Host "🔧 Updating IAM Permissions for Backend Deployment..." -ForegroundColor Green

Write-Host ""
Write-Host "📋 Required Permissions to Add:" -ForegroundColor Yellow
Write-Host "1. CodeBuild permissions" -ForegroundColor Cyan
Write-Host "2. S3 permissions" -ForegroundColor Cyan
Write-Host "3. Amazon Q permissions" -ForegroundColor Cyan
Write-Host "4. Additional ECS permissions" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔗 Manual Steps Required:" -ForegroundColor Yellow
Write-Host "1. Go to AWS IAM Console: https://console.aws.amazon.com/iam/" -ForegroundColor White
Write-Host "2. Find user: rant-zone-deploy" -ForegroundColor White
Write-Host "3. Add these policies:" -ForegroundColor White
Write-Host "   - AWSCodeBuildDeveloperAccess" -ForegroundColor Cyan
Write-Host "   - AmazonS3ReadOnlyAccess" -ForegroundColor Cyan
Write-Host "   - AmazonQDeveloperAccess" -ForegroundColor Cyan
Write-Host "   - AmazonECS-FullAccess" -ForegroundColor Cyan

Write-Host ""
Write-Host "📝 Or create custom policy with this JSON:" -ForegroundColor Yellow
Write-Host @"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:*",
                "s3:*",
                "ecs:*",
                "ecr:*",
                "logs:*",
                "iam:PassRole",
                "iam:GetRole",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeVpcs",
                "elasticloadbalancing:*",
                "ssm:*"
            ],
            "Resource": "*"
        }
    ]
}
"@ -ForegroundColor Gray

Write-Host ""
Write-Host "✅ After updating permissions, run: .\scripts\test-aws-credentials.ps1" -ForegroundColor Green 