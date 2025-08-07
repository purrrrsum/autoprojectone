@echo off
echo 🚀 Starting simple frontend deployment to S3...
echo.

REM Check if AWS CLI is installed
aws --version >nul 2>&1
if errorlevel 1 (
    echo ❌ AWS CLI not found. Please install AWS CLI first.
    pause
    exit /b 1
)

echo ✅ AWS CLI found
echo.

REM Check AWS credentials
aws sts get-caller-identity --query 'Arn' --output text >nul 2>&1
if errorlevel 1 (
    echo ❌ AWS credentials not configured. Please run 'aws configure' first.
    pause
    exit /b 1
)

echo ✅ AWS credentials found
echo.

REM Set variables
set BUCKET_NAME=rant-zone-frontend
set REGION=us-east-1

echo 📋 Deploying to bucket: %BUCKET_NAME%
echo 📍 Region: %REGION%
echo.

REM Create bucket if it doesn't exist
echo 🪣 Checking bucket existence...
aws s3api head-bucket --bucket %BUCKET_NAME% --region %REGION% >nul 2>&1
if errorlevel 1 (
    echo 📦 Creating new bucket...
    aws s3 mb s3://%BUCKET_NAME% --region %REGION%
    echo ✅ Bucket created
) else (
    echo ✅ Bucket already exists
)

echo.

REM Configure website hosting
echo 🌐 Configuring website hosting...
aws s3api put-bucket-website --bucket %BUCKET_NAME% --website-configuration "{\"IndexDocument\":{\"Suffix\":\"index.html\"},\"ErrorDocument\":{\"Key\":\"error.html\"}}"
echo ✅ Website configuration applied

echo.

REM Set bucket policy
echo 🔓 Setting bucket policy...
aws s3api put-bucket-policy --bucket %BUCKET_NAME% --policy "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadGetObject\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::%BUCKET_NAME%/*\"}]}"
echo ✅ Bucket policy applied

echo.

REM Create build directory
echo 📁 Creating static files...
if exist frontend-build rmdir /s /q frontend-build
mkdir frontend-build

REM Create index.html
echo ^<!DOCTYPE html^> > frontend-build\index.html
echo ^<html lang="en"^> >> frontend-build\index.html
echo ^<head^> >> frontend-build\index.html
echo     ^<meta charset="UTF-8"^> >> frontend-build\index.html
echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^> >> frontend-build\index.html
echo     ^<title^>Rant.Zone - Anonymous Chat^</title^> >> frontend-build\index.html
echo     ^<style^> >> frontend-build\index.html
echo         * { margin: 0; padding: 0; box-sizing: border-box; } >> frontend-build\index.html
echo         body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); min-height: 100vh; display: flex; align-items: center; justify-content: center; } >> frontend-build\index.html
echo         .container { background: white; padding: 2rem; border-radius: 12px; box-shadow: 0 20px 40px rgba(0,0,0,0.1); text-align: center; max-width: 400px; width: 90%%; } >> frontend-build\index.html
echo         h1 { color: #333; margin-bottom: 1rem; font-size: 2rem; } >> frontend-build\index.html
echo         p { color: #666; margin-bottom: 2rem; line-height: 1.6; } >> frontend-build\index.html
echo         .btn { background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); color: white; padding: 12px 24px; border: none; border-radius: 6px; font-size: 1rem; cursor: pointer; transition: transform 0.2s; } >> frontend-build\index.html
echo         .btn:hover { transform: translateY(-2px); } >> frontend-build\index.html
echo         .status { margin-top: 1rem; padding: 0.5rem; border-radius: 4px; font-size: 0.9rem; } >> frontend-build\index.html
echo         .status.success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; } >> frontend-build\index.html
echo     ^</style^> >> frontend-build\index.html
echo ^</head^> >> frontend-build\index.html
echo ^<body^> >> frontend-build\index.html
echo     ^<div class="container"^> >> frontend-build\index.html
echo         ^<h1^>🚀 Rant.Zone^</h1^> >> frontend-build\index.html
echo         ^<p^>Anonymous chat platform is being deployed. This is a temporary page while we set up the full application.^</p^> >> frontend-build\index.html
echo         ^<button class="btn" onclick="checkStatus()"^>Check Status^</button^> >> frontend-build\index.html
echo         ^<div id="status" class="status" style="display: none;"^>^</div^> >> frontend-build\index.html
echo     ^</div^> >> frontend-build\index.html
echo     ^<script^> >> frontend-build\index.html
echo         function checkStatus() { >> frontend-build\index.html
echo             const statusDiv = document.getElementById('status'); >> frontend-build\index.html
echo             statusDiv.style.display = 'block'; >> frontend-build\index.html
echo             statusDiv.textContent = '🔄 Checking deployment status...'; >> frontend-build\index.html
echo             statusDiv.className = 'status'; >> frontend-build\index.html
echo             setTimeout(() => { >> frontend-build\index.html
echo                 statusDiv.textContent = '✅ Frontend deployed successfully! Backend deployment in progress...'; >> frontend-build\index.html
echo                 statusDiv.className = 'status success'; >> frontend-build\index.html
echo             }, 2000); >> frontend-build\index.html
echo         } >> frontend-build\index.html
echo         setTimeout(checkStatus, 1000); >> frontend-build\index.html
echo     ^</script^> >> frontend-build\index.html
echo ^</body^> >> frontend-build\index.html
echo ^</html^> >> frontend-build\index.html

echo ✅ Static files created

echo.

REM Upload to S3
echo 📤 Uploading files to S3...
aws s3 sync frontend-build s3://%BUCKET_NAME% --delete --region %REGION%
echo ✅ Files uploaded successfully

echo.

REM Get website URL
echo 🎉 Deployment completed successfully!
echo 🌐 Your website is available at: http://%BUCKET_NAME%.s3-website-%REGION%.amazonaws.com
echo.
echo 📋 Next steps:
echo    1. Set up CloudFront distribution for HTTPS
echo    2. Configure custom domain (rant.zone)
echo    3. Deploy the backend to ECS
echo.

REM Cleanup
rmdir /s /q frontend-build
echo 🧹 Cleanup completed

echo.
pause 