# AWS Backend Deployment Script (Console-based)
# This script deploys the backend to AWS ECS using CodeBuild instead of local Docker

Write-Host "🚀 Starting AWS Backend Deployment (Console-based)..." -ForegroundColor Green

# Step 1: Check AWS credentials
Write-Host "✅ Checking AWS credentials..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity 2>$null | ConvertFrom-Json
    Write-Host "✅ AWS credentials found: $($identity.Arn)" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS credentials not found. Please run 'aws configure' first." -ForegroundColor Red
    exit 1
}

# Step 2: Create CodeBuild project
Write-Host "🔨 Creating CodeBuild project..." -ForegroundColor Yellow

$codebuildConfig = @{
    name = "rant-zone-backend-build"
    source = @{
        type = "GITHUB"
        location = "https://github.com/purrrrsum/autoprojectone"
        gitCloneDepth = 1
    }
    artifacts = @{
        type = "NO_ARTIFACTS"
    }
    environment = @{
        type = "LINUX_CONTAINER"
        image = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
        computeType = "BUILD_GENERAL1_SMALL"
        privilegedMode = $true
        environmentVariables = @(
            @{
                name = "AWS_DEFAULT_REGION"
                value = "us-east-1"
            },
            @{
                name = "IMAGE_REPO_NAME"
                value = "rant-zone-backend"
            },
            @{
                name = "IMAGE_TAG"
                value = "latest"
            }
        )
    }
    serviceRole = "arn:aws:iam::224776848598:role/service-role/codebuild-rant-zone-backend-build-service-role"
}

$codebuildConfigJson = $codebuildConfig | ConvertTo-Json -Depth 10

# Create CodeBuild project
aws codebuild create-project --cli-input-json $codebuildConfigJson --region us-east-1

# Step 3: Create buildspec.yml for CodeBuild
$buildspec = @"
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 224776848598.dkr.ecr.us-east-1.amazonaws.com
      - REPOSITORY_URI=224776848598.dkr.ecr.us-east-1.amazonaws.com/rant-zone-backend
      - IMAGE_TAG=latest
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - cd backend
      - docker build -f Dockerfile.aws -t `$REPOSITORY_URI:`$IMAGE_TAG .
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push `$REPOSITORY_URI:`$IMAGE_TAG
      - echo Writing image definitions file...
      - printf '[{"name":"rant-zone-backend","imageUri":"%s"}]' `$REPOSITORY_URI:`$IMAGE_TAG > imagedefinitions.json
artifacts:
  files:
    - imagedefinitions.json
"@

$buildspec | Out-File -FilePath "buildspec.yml" -Encoding UTF8

Write-Host "✅ Buildspec.yml created" -ForegroundColor Green

# Step 4: Create ECS Task Definition
Write-Host "📋 Creating ECS Task Definition..." -ForegroundColor Yellow

$taskDefinition = @{
    family = "rant-zone-backend"
    networkMode = "awsvpc"
    requiresCompatibilities = @("FARGATE")
    cpu = "256"
    memory = "512"
    executionRoleArn = "arn:aws:iam::224776848598:role/ecsTaskExecutionRole"
    taskRoleArn = "arn:aws:iam::224776848598:role/ecsTaskExecutionRole"
    containerDefinitions = @(
        @{
            name = "rant-zone-backend"
            image = "224776848598.dkr.ecr.us-east-1.amazonaws.com/rant-zone-backend:latest"
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
            secrets = @(
                @{
                    name = "DATABASE_URL"
                    valueFrom = "arn:aws:ssm:us-east-1:224776848598:parameter/rant-zone/database-url"
                },
                @{
                    name = "REDIS_URL"
                    valueFrom = "arn:aws:ssm:us-east-1:224776848598:parameter/rant-zone/redis-url"
                },
                @{
                    name = "JWT_SECRET"
                    valueFrom = "arn:aws:ssm:us-east-1:224776848598:parameter/rant-zone/jwt-secret"
                }
            )
            logConfiguration = @{
                logDriver = "awslogs"
                options = @{
                    "awslogs-group" = "/ecs/rant-zone-backend"
                    "awslogs-region" = "us-east-1"
                    "awslogs-stream-prefix" = "ecs"
                }
            }
            healthCheck = @{
                command = @("CMD-SHELL", "curl -f http://localhost:3001/health || exit 1")
                interval = 30
                timeout = 5
                retries = 3
                startPeriod = 60
            }
        }
    )
}

$taskDefinitionJson = $taskDefinition | ConvertTo-Json -Depth 10

# Register task definition
aws ecs register-task-definition --cli-input-json $taskDefinitionJson --region us-east-1

Write-Host "✅ Task Definition created" -ForegroundColor Green

# Step 5: Create ECS Service
Write-Host "🚀 Creating ECS Service..." -ForegroundColor Yellow

$serviceConfig = @{
    cluster = "rant-zone-cluster"
    serviceName = "rant-zone-backend-service"
    taskDefinition = "rant-zone-backend"
    desiredCount = 1
    launchType = "FARGATE"
    networkConfiguration = @{
        awsvpcConfiguration = @{
            subnets = @("subnet-12345678", "subnet-87654321")  # Replace with your subnet IDs
            securityGroups = @("sg-12345678")  # Replace with your security group ID
            assignPublicIp = "ENABLED"
        }
    }
}

$serviceConfigJson = $serviceConfig | ConvertTo-Json -Depth 10

# Create service
aws ecs create-service --cli-input-json $serviceConfigJson --region us-east-1

Write-Host "✅ ECS Service created" -ForegroundColor Green

Write-Host "🎉 Backend deployment initiated!" -ForegroundColor Green
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Check AWS CodeBuild console for build status"
Write-Host "   2. Check ECS console for service status"
Write-Host "   3. Update frontend API URLs once backend is running" 