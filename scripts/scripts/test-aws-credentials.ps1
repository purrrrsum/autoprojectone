# Test AWS Credentials and Permissions
Write-Host "🔍 Testing AWS Credentials and Permissions..." -ForegroundColor Green

# Test 1: Check AWS CLI and credentials
Write-Host "`n📋 Test 1: AWS CLI and Credentials" -ForegroundColor Yellow
try {
    $awsVersion = aws --version 2>$null
    if ($awsVersion) {
        Write-Host "✅ AWS CLI found: $awsVersion" -ForegroundColor Green
    } else {
        throw "AWS CLI not found"
    }
} catch {
    Write-Host "❌ AWS CLI not found. Please install AWS CLI first." -ForegroundColor Red
    exit 1
}

# Test 2: Check AWS credentials
Write-Host "`n🔐 Test 2: AWS Credentials" -ForegroundColor Yellow
try {
    $callerIdentity = aws sts get-caller-identity --query 'Arn' --output text 2>$null
    if ($callerIdentity) {
        Write-Host "✅ AWS credentials found: $callerIdentity" -ForegroundColor Green
        $accountId = aws sts get-caller-identity --query 'Account' --output text
        Write-Host "   Account ID: $accountId" -ForegroundColor Cyan
    } else {
        throw "No credentials"
    }
} catch {
    Write-Host "❌ AWS credentials not configured. Please run 'aws configure' first." -ForegroundColor Red
    Write-Host "   Required: AWS Access Key ID and Secret Access Key" -ForegroundColor Yellow
    exit 1
}

# Test 3: Check ECR permissions
Write-Host "`n🐳 Test 3: ECR Permissions" -ForegroundColor Yellow
try {
    aws ecr describe-repositories --region us-east-1 --max-items 1 >$null 2>&1
    Write-Host "✅ ECR permissions OK" -ForegroundColor Green
} catch {
    Write-Host "❌ ECR permissions failed. Check IAM permissions." -ForegroundColor Red
}

# Test 4: Check ECS permissions
Write-Host "`n🏗️ Test 4: ECS Permissions" -ForegroundColor Yellow
try {
    aws ecs list-clusters --region us-east-1 --max-items 1 >$null 2>&1
    Write-Host "✅ ECS permissions OK" -ForegroundColor Green
} catch {
    Write-Host "❌ ECS permissions failed. Check IAM permissions." -ForegroundColor Red
}

# Test 5: Check SSM permissions
Write-Host "`n🔒 Test 5: SSM Parameter Store Permissions" -ForegroundColor Yellow
try {
    aws ssm describe-parameters --region us-east-1 --max-items 1 >$null 2>&1
    Write-Host "✅ SSM permissions OK" -ForegroundColor Green
} catch {
    Write-Host "❌ SSM permissions failed. Check IAM permissions." -ForegroundColor Red
}

# Test 6: Check CloudWatch permissions
Write-Host "`n📊 Test 6: CloudWatch Logs Permissions" -ForegroundColor Yellow
try {
    aws logs describe-log-groups --region us-east-1 --max-items 1 >$null 2>&1
    Write-Host "✅ CloudWatch permissions OK" -ForegroundColor Green
} catch {
    Write-Host "❌ CloudWatch permissions failed. Check IAM permissions." -ForegroundColor Red
}

# Test 7: Check Docker
Write-Host "`n🐳 Test 7: Docker Installation" -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-Host "✅ Docker found: $dockerVersion" -ForegroundColor Green
    } else {
        throw "Docker not found"
    }
} catch {
    Write-Host "❌ Docker not found. Please install Docker Desktop." -ForegroundColor Red
    Write-Host "   Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
}

# Summary
Write-Host "`n📋 Summary:" -ForegroundColor Green
Write-Host "✅ All tests completed. If you see any ❌ errors above," -ForegroundColor Yellow
Write-Host "   please fix them before running the deployment scripts." -ForegroundColor Yellow

Write-Host "`n🚀 Ready to deploy? Run the deployment script when all tests pass!" -ForegroundColor Green 