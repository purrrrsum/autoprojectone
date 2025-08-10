# Deploy Frontend with Theme Updates to S3
# This script deploys the built Next.js application with our new theme

param(
    [string]$BucketName = "rant-zone-frontend-7115",
    [string]$Region = "us-east-1"
)

Write-Host "🚀 Starting frontend deployment with theme updates..." -ForegroundColor Green

# Step 1: Check AWS CLI
Write-Host "📋 Checking AWS CLI..." -ForegroundColor Yellow
try {
    $awsVersion = aws --version
    Write-Host "✅ AWS CLI found: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS CLI not found. Please install AWS CLI first." -ForegroundColor Red
    exit 1
}

# Step 2: Check AWS credentials
Write-Host "🔐 Checking AWS credentials..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity --query 'Arn' --output text
    Write-Host "✅ AWS credentials found: $identity" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS credentials not configured. Please run 'aws configure' first." -ForegroundColor Red
    exit 1
}

# Step 3: Check if bucket exists
Write-Host "🪣 Checking S3 bucket..." -ForegroundColor Yellow
try {
    aws s3api head-bucket --bucket $BucketName --region $Region 2>$null
    Write-Host "✅ Bucket '$BucketName' exists" -ForegroundColor Green
} catch {
    Write-Host "❌ Bucket '$BucketName' not found. Please create it first." -ForegroundColor Red
    exit 1
}

# Step 4: Check if frontend build exists
Write-Host "📁 Checking frontend build..." -ForegroundColor Yellow
$buildDir = "frontend/out"
if (-not (Test-Path $buildDir)) {
    Write-Host "❌ Frontend build not found at '$buildDir'. Please run 'npm run build' in the frontend directory first." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Frontend build found" -ForegroundColor Green

# Step 5: Configure bucket for static website hosting
Write-Host "🌐 Configuring bucket for static website hosting..." -ForegroundColor Yellow
$websiteConfig = @{
    IndexDocument = @{Suffix = "index.html"}
    ErrorDocument = @{Key = "404.html"}
} | ConvertTo-Json

aws s3api put-bucket-website --bucket $BucketName --website-configuration $websiteConfig
Write-Host "✅ Website configuration applied" -ForegroundColor Green

# Step 6: Set bucket policy for public read access
Write-Host "🔓 Setting bucket policy for public read access..." -ForegroundColor Yellow
$bucketPolicy = @{
    Version = "2012-10-17"
    Statement = @(
        @{
            Sid = "PublicReadGetObject"
            Effect = "Allow"
            Principal = "*"
            Action = "s3:GetObject"
            Resource = "arn:aws:s3:::$BucketName/*"
        }
    )
} | ConvertTo-Json

aws s3api put-bucket-policy --bucket $BucketName --policy $bucketPolicy
Write-Host "✅ Bucket policy applied" -ForegroundColor Green

# Step 7: Upload built files to S3
Write-Host "📤 Uploading built files to S3..." -ForegroundColor Yellow
aws s3 sync $buildDir s3://$BucketName --delete --region $Region
Write-Host "✅ Files uploaded successfully" -ForegroundColor Green

# Step 8: Get the website URL
$websiteUrl = "http://$BucketName.s3-website-$Region.amazonaws.com"

Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
Write-Host "🌐 Your website with theme updates is available at: $websiteUrl" -ForegroundColor Cyan
Write-Host "📋 Theme features included:" -ForegroundColor Yellow
Write-Host "   ✅ Light/Dark/System theme toggle" -ForegroundColor White
Write-Host "   ✅ Rant.Zone logo in header" -ForegroundColor White
Write-Host "   ✅ Theme-aware styling" -ForegroundColor White
Write-Host "   ✅ Responsive design" -ForegroundColor White
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Test the website at: $websiteUrl" -ForegroundColor White
Write-Host "   2. Check theme toggle functionality" -ForegroundColor White
Write-Host "   3. Verify logo display" -ForegroundColor White
Write-Host "   4. Test responsive design" -ForegroundColor White

Write-Host "🔗 CloudFront URL: https://djxgybv2umfrz.cloudfront.net" -ForegroundColor Cyan
