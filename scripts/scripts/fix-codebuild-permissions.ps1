# Fix CodeBuild IAM Permissions
Write-Host "🔧 Fixing CodeBuild IAM Permissions..." -ForegroundColor Green

Write-Host ""
Write-Host "❌ Error: User needs IAM role creation permissions" -ForegroundColor Red
Write-Host "Error: iam:CreateRole permission required" -ForegroundColor Red

Write-Host ""
Write-Host "🔧 Solutions:" -ForegroundColor Yellow

Write-Host ""
Write-Host "Option 1: Add IAM Permissions (Recommended)" -ForegroundColor Cyan
Write-Host "1. Go to AWS IAM Console: https://console.aws.amazon.com/iam/" -ForegroundColor White
Write-Host "2. Find user: rant-zone-deploy" -ForegroundColor White
Write-Host "3. Add these policies:" -ForegroundColor White
Write-Host "   - AWSCodeBuildDeveloperAccess" -ForegroundColor Cyan
Write-Host "   - IAMFullAccess (or custom policy)" -ForegroundColor Cyan

Write-Host ""
Write-Host "Option 2: Create Custom Policy (More Secure)" -ForegroundColor Cyan
Write-Host "Create this JSON policy:" -ForegroundColor White
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
Write-Host "Option 3: Use Existing Service Role" -ForegroundColor Cyan
Write-Host "1. In CodeBuild project creation:" -ForegroundColor White
Write-Host "2. Choose 'Use an existing service role'" -ForegroundColor White
Write-Host "3. Role name: AWSCodeBuildServiceRole" -ForegroundColor White

Write-Host ""
Write-Host "🎯 Recommended Steps:" -ForegroundColor Yellow
Write-Host "1. Add AWSCodeBuildDeveloperAccess policy to your user" -ForegroundColor Cyan
Write-Host "2. Add IAMFullAccess policy (temporarily)" -ForegroundColor Cyan
Write-Host "3. Create CodeBuild project" -ForegroundColor Cyan
Write-Host "4. Remove IAMFullAccess after project creation" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔗 AWS Console Links:" -ForegroundColor Yellow
Write-Host "IAM Console: https://console.aws.amazon.com/iam/" -ForegroundColor Cyan
Write-Host "CodeBuild Console: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor Cyan 