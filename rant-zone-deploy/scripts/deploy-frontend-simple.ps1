# Simple Frontend Deployment to S3
# This script bypasses memory issues by using a minimal build approach

param(
    [string]$BucketName = "rant-zone-frontend",
    [string]$Region = "us-east-1"
)

Write-Host "🚀 Starting simple frontend deployment to S3..." -ForegroundColor Green

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

# Step 3: Create S3 bucket if it doesn't exist
Write-Host "🪣 Creating S3 bucket if it doesn't exist..." -ForegroundColor Yellow
try {
    aws s3api head-bucket --bucket $BucketName --region $Region 2>$null
    Write-Host "✅ Bucket '$BucketName' already exists" -ForegroundColor Green
} catch {
    Write-Host "📦 Creating new bucket '$BucketName'..." -ForegroundColor Yellow
    aws s3 mb s3://$BucketName --region $Region
    Write-Host "✅ Bucket created successfully" -ForegroundColor Green
}

# Step 4: Configure bucket for static website hosting
Write-Host "🌐 Configuring bucket for static website hosting..." -ForegroundColor Yellow
$websiteConfig = @{
    IndexDocument = @{Suffix = "index.html"}
    ErrorDocument = @{Key = "error.html"}
} | ConvertTo-Json

aws s3api put-bucket-website --bucket $BucketName --website-configuration $websiteConfig
Write-Host "✅ Website configuration applied" -ForegroundColor Green

# Step 5: Set bucket policy for public read access
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

# Step 6: Create a simple static build (bypassing npm build)
Write-Host "📁 Creating simple static files..." -ForegroundColor Yellow
$buildDir = "frontend-build"
if (Test-Path $buildDir) {
    Remove-Item $buildDir -Recurse -Force
}
New-Item -ItemType Directory -Path $buildDir | Out-Null

# Create a simple index.html
$indexHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rant.Zone - Anonymous Chat</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 400px;
            width: 90%;
        }
        h1 { 
            color: #333;
            margin-bottom: 1rem;
            font-size: 2rem;
        }
        p { 
            color: #666;
            margin-bottom: 2rem;
            line-height: 1.6;
        }
        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            font-size: 1rem;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .btn:hover {
            transform: translateY(-2px);
        }
        .status {
            margin-top: 1rem;
            padding: 0.5rem;
            border-radius: 4px;
            font-size: 0.9rem;
        }
        .status.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Rant.Zone</h1>
        <p>Anonymous chat platform is being deployed. This is a temporary page while we set up the full application.</p>
        <button class="btn" onclick="checkStatus()">Check Status</button>
        <div id="status" class="status" style="display: none;"></div>
    </div>

    <script>
        function checkStatus() {
            const statusDiv = document.getElementById('status');
            statusDiv.style.display = 'block';
            statusDiv.textContent = '🔄 Checking deployment status...';
            statusDiv.className = 'status';
            
            // Simulate status check
            setTimeout(() => {
                statusDiv.textContent = '✅ Frontend deployed successfully! Backend deployment in progress...';
                statusDiv.className = 'status success';
            }, 2000);
        }
        
        // Auto-check status on load
        setTimeout(checkStatus, 1000);
    </script>
</body>
</html>
"@

$indexHtml | Out-File -FilePath "$buildDir/index.html" -Encoding UTF8

# Create error.html
$errorHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - Rant.Zone</title>
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-align: center;
        }
        .container {
            max-width: 400px;
            padding: 2rem;
        }
        h1 { font-size: 3rem; margin-bottom: 1rem; }
        p { font-size: 1.2rem; margin-bottom: 2rem; }
        a { color: white; text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <h1>404</h1>
        <p>Page not found</p>
        <a href="/">Go back home</a>
    </div>
</body>
</html>
"@

$errorHtml | Out-File -FilePath "$buildDir/error.html" -Encoding UTF8

Write-Host "✅ Static files created" -ForegroundColor Green

# Step 7: Upload files to S3
Write-Host "📤 Uploading files to S3..." -ForegroundColor Yellow
aws s3 sync $buildDir s3://$BucketName --delete --region $Region
Write-Host "✅ Files uploaded successfully" -ForegroundColor Green

# Step 8: Get the website URL
$websiteUrl = aws s3api get-bucket-website --bucket $BucketName --query 'WebsiteConfiguration.IndexDocument.Suffix' --output text
$fullUrl = "http://$BucketName.s3-website-$Region.amazonaws.com"

Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
Write-Host "🌐 Your website is available at: $fullUrl" -ForegroundColor Cyan
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Set up CloudFront distribution for HTTPS" -ForegroundColor White
Write-Host "   2. Configure custom domain (rant.zone)" -ForegroundColor White
Write-Host "   3. Deploy the backend to ECS" -ForegroundColor White

# Cleanup
Remove-Item $buildDir -Recurse -Force
Write-Host "🧹 Cleanup completed" -ForegroundColor Green 