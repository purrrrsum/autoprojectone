# Check Backend Deployment Status
Write-Host "🔍 Checking Backend Deployment Status..." -ForegroundColor Green

Write-Host ""
Write-Host "📊 Current Status Overview:" -ForegroundColor Yellow

# Check ECR Images
Write-Host "1. Checking ECR Images..." -ForegroundColor Cyan
try {
    $images = aws ecr describe-images --repository-name rant-zone-backend --region us-east-1 --query "imageDetails" --output json 2>$null
    if ($images) {
        $imageData = $images | ConvertFrom-Json
        $imageCount = $imageData.Count
        if ($imageCount -gt 0) {
            Write-Host "   ✅ Found $imageCount image(s) in ECR" -ForegroundColor Green
            $latestImage = $imageData[0]
            Write-Host "   📅 Latest: $($latestImage.pushedAt)" -ForegroundColor Cyan
        } else {
            Write-Host "   ❌ No images found in ECR" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ No images found in ECR" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Error checking ECR images" -ForegroundColor Red
}

# Check ECS Services
Write-Host ""
Write-Host "2. Checking ECS Services..." -ForegroundColor Cyan
try {
    $services = aws ecs list-services --cluster rant-zone-cluster --region us-east-1 --query "serviceArns" --output json 2>$null
    if ($services) {
        $serviceData = $services | ConvertFrom-Json
        $serviceCount = $serviceData.Count
        if ($serviceCount -gt 0) {
            Write-Host "   ✅ Found $serviceCount service(s) in ECS cluster" -ForegroundColor Green
            foreach ($service in $serviceData) {
                $serviceName = $service.Split('/')[-1]
                Write-Host "   📋 Service: $serviceName" -ForegroundColor Cyan
            }
        } else {
            Write-Host "   ❌ No services found in ECS cluster" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ No services found in ECS cluster" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Error checking ECS services" -ForegroundColor Red
}

# Check ECS Tasks
Write-Host ""
Write-Host "3. Checking ECS Tasks..." -ForegroundColor Cyan
try {
    $tasks = aws ecs list-tasks --cluster rant-zone-cluster --region us-east-1 --query "taskArns" --output json 2>$null
    if ($tasks) {
        $taskData = $tasks | ConvertFrom-Json
        $taskCount = $taskData.Count
        if ($taskCount -gt 0) {
            Write-Host "   ✅ Found $taskCount running task(s)" -ForegroundColor Green
            foreach ($task in $taskData) {
                Write-Host "   📋 Task: $($task.Split('/')[-1])" -ForegroundColor Cyan
            }
        } else {
            Write-Host "   ❌ No running tasks found" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ No running tasks found" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Error checking ECS tasks" -ForegroundColor Red
}

# Check Load Balancers
Write-Host ""
Write-Host "4. Checking Load Balancers..." -ForegroundColor Cyan
try {
    $loadBalancers = aws elbv2 describe-load-balancers --region us-east-1 --query "LoadBalancers[?contains(LoadBalancerName, 'rant-zone')].{Name:LoadBalancerName,DNSName:DNSName,State:State.Code}" --output json 2>$null
    if ($loadBalancers) {
        $lbData = $loadBalancers | ConvertFrom-Json
        $lbCount = $lbData.Count
        if ($lbCount -gt 0) {
            Write-Host "   ✅ Found $lbCount load balancer(s)" -ForegroundColor Green
            foreach ($lb in $lbData) {
                Write-Host "   📋 LB: $($lb.Name) - State: $($lb.State)" -ForegroundColor Cyan
                Write-Host "   🌐 DNS: $($lb.DNSName)" -ForegroundColor Green
            }
        } else {
            Write-Host "   ❌ No load balancers found" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ No load balancers found" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Error checking load balancers" -ForegroundColor Red
}

# Check SSM Parameters
Write-Host ""
Write-Host "5. Checking Environment Variables..." -ForegroundColor Cyan
try {
    $parameters = aws ssm describe-parameters --region us-east-1 --query "Parameters[?starts_with(Name, '/rant-zone/')].Name" --output json 2>$null
    if ($parameters) {
        $paramData = $parameters | ConvertFrom-Json
        $paramCount = $paramData.Count
        if ($paramCount -gt 0) {
            Write-Host "   ✅ Found $paramCount environment variables" -ForegroundColor Green
            foreach ($param in $paramData) {
                Write-Host "   📋 $param" -ForegroundColor Cyan
            }
        } else {
            Write-Host "   ❌ No environment variables found" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ No environment variables found" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Error checking environment variables" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 Summary:" -ForegroundColor Yellow
Write-Host "If you see ❌ errors above, you need to:" -ForegroundColor Red
Write-Host "1. Update IAM permissions: .\scripts\update-iam-permissions.ps1" -ForegroundColor Cyan
Write-Host "2. Create CodeBuild project: .\scripts\create-codebuild-project.ps1" -ForegroundColor Cyan
Write-Host "3. Build and deploy: .\scripts\build-and-deploy-backend.ps1" -ForegroundColor Cyan
Write-Host "4. Create ECS service: .\scripts\create-ecs-service.ps1" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔗 Useful Links:" -ForegroundColor Yellow
Write-Host "ECS Console: https://console.aws.amazon.com/ecs/" -ForegroundColor Cyan
Write-Host "CodeBuild Console: https://console.aws.amazon.com/codesuite/codebuild/" -ForegroundColor Cyan
Write-Host "ECR Console: https://console.aws.amazon.com/ecr/" -ForegroundColor Cyan 