# Backend Deployment to ECS
# This script deploys the backend to AWS ECS Fargate

param(
    [string]$ClusterName = "rant-zone-cluster",
    [string]$ServiceName = "rant-zone-backend",
    [string]$TaskDefinitionName = "rant-zone-backend-task",
    [string]$Region = "us-east-1"
)

Write-Host "🚀 Starting backend deployment to ECS..." -ForegroundColor Green

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

# Step 3: Create ECR repository
Write-Host "📦 Creating ECR repository..." -ForegroundColor Yellow
$repositoryName = "rant-zone-backend"
try {
    aws ecr describe-repositories --repository-names $repositoryName --region $Region 2>$null
    Write-Host "✅ Repository already exists" -ForegroundColor Green
} catch {
    aws ecr create-repository --repository-name $repositoryName --region $Region
    Write-Host "✅ Repository created" -ForegroundColor Green
}

# Step 4: Get ECR login token
Write-Host "🔑 Getting ECR login token..." -ForegroundColor Yellow
$accountId = aws sts get-caller-identity --query 'Account' --output text
$ecrUri = "$accountId.dkr.ecr.$Region.amazonaws.com"
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $ecrUri
Write-Host "✅ ECR login successful" -ForegroundColor Green

# Step 5: Build and push Docker image
Write-Host "🐳 Building Docker image..." -ForegroundColor Yellow
$imageTag = "latest"
$imageUri = "$ecrUri/$repositoryName:$imageTag"

# Build the image
docker build -t $repositoryName ../backend/
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed" -ForegroundColor Red
    exit 1
}

# Tag the image
docker tag "${repositoryName}:${imageTag}" $imageUri

# Push the image
docker push $imageUri
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker push failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker image pushed successfully" -ForegroundColor Green

# Step 6: Create ECS cluster
Write-Host "🏗️ Creating ECS cluster..." -ForegroundColor Yellow
try {
    aws ecs describe-clusters --clusters $ClusterName --region $Region 2>$null
    Write-Host "✅ Cluster already exists" -ForegroundColor Green
} catch {
    aws ecs create-cluster --cluster-name $ClusterName --region $Region
    Write-Host "✅ Cluster created" -ForegroundColor Green
}

# Step 7: Create task definition
Write-Host "📝 Creating task definition..." -ForegroundColor Yellow
$taskDefinition = @{
    family = $TaskDefinitionName
    networkMode = "awsvpc"
    requiresCompatibilities = @("FARGATE")
    cpu = "256"
    memory = "512"
    executionRoleArn = "ecsTaskExecutionRole"
    containerDefinitions = @(
        @{
            name = "rant-zone-backend"
            image = $imageUri
            portMappings = @(
                @{
                    containerPort = 3001
                    protocol = "tcp"
                }
            )
            environment = @(
                @{
                    name = "NODE_ENV"
                    value = "production"
                },
                @{
                    name = "PORT"
                    value = "3001"
                }
            )
            logConfiguration = @{
                logDriver = "awslogs"
                options = @{
                    "awslogs-group" = "/ecs/$TaskDefinitionName"
                    "awslogs-region" = $Region
                    "awslogs-stream-prefix" = "ecs"
                }
            }
        }
    )
} | ConvertTo-Json -Depth 10

$taskDefinition | Out-File -FilePath "task-definition.json" -Encoding UTF8
aws ecs register-task-definition --cli-input-json file://task-definition.json --region $Region
Write-Host "✅ Task definition created" -ForegroundColor Green

# Step 8: Create service
Write-Host "🔧 Creating ECS service..." -ForegroundColor Yellow
$serviceDefinition = @{
    cluster = $ClusterName
    serviceName = $ServiceName
    taskDefinition = $TaskDefinitionName
    desiredCount = 1
    launchType = "FARGATE"
    networkConfiguration = @{
        awsvpcConfiguration = @{
            subnets = @("subnet-12345678", "subnet-87654321")  # Replace with actual subnet IDs
            securityGroups = @("sg-12345678")  # Replace with actual security group ID
            assignPublicIp = "ENABLED"
        }
    }
} | ConvertTo-Json -Depth 10

$serviceDefinition | Out-File -FilePath "service-definition.json" -Encoding UTF8
aws ecs create-service --cli-input-json file://service-definition.json --region $Region
Write-Host "✅ Service created" -ForegroundColor Green

# Step 9: Wait for service to be stable
Write-Host "⏳ Waiting for service to be stable..." -ForegroundColor Yellow
aws ecs wait services-stable --cluster $ClusterName --services $ServiceName --region $Region
Write-Host "✅ Service is stable" -ForegroundColor Green

# Step 10: Get service details
Write-Host "📊 Getting service details..." -ForegroundColor Yellow
$serviceDetails = aws ecs describe-services --cluster $ClusterName --services $ServiceName --region $Region --query 'services[0]' --output json | ConvertFrom-Json

Write-Host "🎉 Backend deployment completed successfully!" -ForegroundColor Green
Write-Host "📋 Service ARN: $($serviceDetails.serviceArn)" -ForegroundColor Cyan
Write-Host "📋 Task Definition ARN: $($serviceDetails.taskDefinition)" -ForegroundColor Cyan
Write-Host "📋 Desired Count: $($serviceDetails.desiredCount)" -ForegroundColor Cyan

Write-Host "`n📋 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Set up Application Load Balancer" -ForegroundColor White
Write-Host "   2. Configure target group" -ForegroundColor White
Write-Host "   3. Set up health checks" -ForegroundColor White
Write-Host "   4. Update DNS records" -ForegroundColor White

# Cleanup
Remove-Item "task-definition.json" -ErrorAction SilentlyContinue
Remove-Item "service-definition.json" -ErrorAction SilentlyContinue
Write-Host "🧹 Cleanup completed" -ForegroundColor Green 