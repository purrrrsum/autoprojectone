# AWS ECS Backend Deployment Script
param(
    [string]$ClusterName = "rant-zone-cluster",
    [string]$ServiceName = "rant-zone-backend",
    [string]$TaskDefinitionName = "rant-zone-backend-task",
    [string]$Region = "us-east-1",
    [string]$RepositoryName = "rant-zone-backend"
)

Write-Host "🚀 Starting AWS ECS Backend Deployment..." -ForegroundColor Green

# Step 1: Check AWS CLI
Write-Host "🔍 Checking AWS CLI..." -ForegroundColor Yellow
try {
    aws --version | Out-Null
    Write-Host "✅ AWS CLI found" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS CLI not found. Please install AWS CLI first." -ForegroundColor Red
    exit 1
}

# Step 2: Check AWS credentials
Write-Host "🔐 Checking AWS credentials..." -ForegroundColor Yellow
try {
    $callerIdentity = aws sts get-caller-identity --query 'Arn' --output text 2>$null
    if ($callerIdentity) {
        Write-Host "✅ AWS credentials found: $callerIdentity" -ForegroundColor Green
    } else {
        throw "No credentials"
    }
} catch {
    Write-Host "❌ AWS credentials not configured. Please run 'aws configure' first." -ForegroundColor Red
    exit 1
}

# Step 3: Create ECR repository
Write-Host "📦 Creating ECR repository..." -ForegroundColor Yellow
try {
    aws ecr describe-repositories --repository-names $RepositoryName --region $Region 2>$null
    Write-Host "✅ ECR repository already exists" -ForegroundColor Green
} catch {
    aws ecr create-repository --repository-name $RepositoryName --region $Region
    Write-Host "✅ ECR repository created" -ForegroundColor Green
}

# Step 4: Get ECR login token
Write-Host "🔑 Getting ECR login token..." -ForegroundColor Yellow
$accountId = aws sts get-caller-identity --query 'Account' --output text
$imageUri = "$accountId.dkr.ecr.$Region.amazonaws.com/$RepositoryName"
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $imageUri
Write-Host "✅ ECR login successful" -ForegroundColor Green

# Step 5: Build and push Docker image
Write-Host "🐳 Building and pushing Docker image..." -ForegroundColor Yellow
Set-Location "rant-zone-deploy/backend"
docker build -t $RepositoryName .
docker tag $RepositoryName`:latest $imageUri`:latest
docker push $imageUri`:latest
Write-Host "✅ Docker image pushed successfully" -ForegroundColor Green

# Step 6: Create ECS cluster
Write-Host "🏗️ Creating ECS cluster..." -ForegroundColor Yellow
try {
    aws ecs describe-clusters --clusters $ClusterName --region $Region 2>$null
    Write-Host "✅ ECS cluster already exists" -ForegroundColor Green
} catch {
    aws ecs create-cluster --cluster-name $ClusterName --region $Region
    Write-Host "✅ ECS cluster created" -ForegroundColor Green
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
                },
                @{
                    name = "HOST"
                    value = "0.0.0.0"
                }
            )
            secrets = @(
                @{
                    name = "DATABASE_URL"
                    valueFrom = "arn:aws:ssm:$Region`:$accountId`:parameter/rant-zone/database-url"
                },
                @{
                    name = "REDIS_URL"
                    valueFrom = "arn:aws:ssm:$Region`:$accountId`:parameter/rant-zone/redis-url"
                },
                @{
                    name = "JWT_SECRET"
                    valueFrom = "arn:aws:ssm:$Region`:$accountId`:parameter/rant-zone/jwt-secret"
                },
                @{
                    name = "ENCRYPTION_KEY"
                    valueFrom = "arn:aws:ssm:$Region`:$accountId`:parameter/rant-zone/encryption-key"
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

# Step 8: Create Application Load Balancer (if needed)
Write-Host "⚖️ Setting up load balancer..." -ForegroundColor Yellow
# This step requires VPC and subnet configuration
# For now, we'll create a simple service without load balancer

# Step 9: Create service
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

# Step 10: Wait for service to be stable
Write-Host "⏳ Waiting for service to be stable..." -ForegroundColor Yellow
do {
    $serviceStatus = aws ecs describe-services --cluster $ClusterName --services $ServiceName --region $Region --query 'services[0].status' --output text
    Write-Host "Service status: $serviceStatus" -ForegroundColor Cyan
    if ($serviceStatus -eq "ACTIVE") {
        break
    }
    Start-Sleep -Seconds 30
} while ($true)

Write-Host "✅ Service is now stable" -ForegroundColor Green

# Step 11: Get service details
Write-Host "📊 Getting service details..." -ForegroundColor Yellow
$serviceDetails = aws ecs describe-services --cluster $ClusterName --services $ServiceName --region $Region
Write-Host "✅ Service deployed successfully" -ForegroundColor Green

# Cleanup
Remove-Item "task-definition.json" -ErrorAction SilentlyContinue
Remove-Item "service-definition.json" -ErrorAction SilentlyContinue

Write-Host "🎉 Backend deployment completed successfully!" -ForegroundColor Green
Write-Host "🌐 Your backend is now running on AWS ECS" -ForegroundColor Cyan
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Configure load balancer for public access" -ForegroundColor White
Write-Host "   2. Update frontend API URLs" -ForegroundColor White
Write-Host "   3. Test the full application" -ForegroundColor White 