# Create ECS Service for Backend Deployment
Write-Host "🚀 Creating ECS Service for Backend Deployment..." -ForegroundColor Green

# Check if ECS service already exists
Write-Host "Checking if ECS service exists..." -ForegroundColor Yellow
try {
    $existingServices = aws ecs list-services --cluster rant-zone-cluster --region us-east-1 --query "serviceArns[?contains(@, 'rant-zone-backend')]" --output text 2>$null
    if ($existingServices) {
        Write-Host "✅ ECS service already exists: $existingServices" -ForegroundColor Green
        Write-Host "You can skip this step and proceed to check the service status." -ForegroundColor Cyan
        exit 0
    }
} catch {
    Write-Host "No existing service found, creating new one..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Manual Steps to Create ECS Service:" -ForegroundColor Yellow
Write-Host "1. Go to AWS ECS Console: https://console.aws.amazon.com/ecs/" -ForegroundColor White
Write-Host "2. Click on cluster: rant-zone-cluster" -ForegroundColor White
Write-Host "3. Click 'Create Service'" -ForegroundColor White
Write-Host "4. Configure service settings:" -ForegroundColor White
Write-Host "   - Launch type: FARGATE" -ForegroundColor Cyan
Write-Host "   - Task Definition: rant-zone-backend" -ForegroundColor Cyan
Write-Host "   - Service name: rant-zone-backend-service" -ForegroundColor Cyan
Write-Host "   - Number of tasks: 1" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Network configuration:" -ForegroundColor White
Write-Host "   - VPC: Default VPC" -ForegroundColor Cyan
Write-Host "   - Subnets: Select all available subnets" -ForegroundColor Cyan
Write-Host "   - Security groups: Create new security group" -ForegroundColor Cyan
Write-Host "     - Name: rant-zone-backend-sg" -ForegroundColor Cyan
Write-Host "     - Description: Security group for Rant.Zone backend" -ForegroundColor Cyan
Write-Host "     - Inbound rules:" -ForegroundColor Cyan
Write-Host "       - TCP 3001 from 0.0.0.0/0 (for health checks)" -ForegroundColor Cyan
Write-Host "       - TCP 80 from 0.0.0.0/0 (for ALB)" -ForegroundColor Cyan
Write-Host "       - TCP 443 from 0.0.0.0/0 (for ALB)" -ForegroundColor Cyan
Write-Host ""
Write-Host "6. Load Balancer (Optional):" -ForegroundColor White
Write-Host "   - Load balancer type: Application Load Balancer" -ForegroundColor Cyan
Write-Host "   - Service IAM role: AWSServiceRoleForECS" -ForegroundColor Cyan
Write-Host "   - Target group: Create new" -ForegroundColor Cyan
Write-Host "     - Target group name: rant-zone-backend-tg" -ForegroundColor Cyan
Write-Host "     - Target type: IP" -ForegroundColor Cyan
Write-Host "     - Protocol: HTTP" -ForegroundColor Cyan
Write-Host "     - Port: 3001" -ForegroundColor Cyan
Write-Host "     - Health check path: /health" -ForegroundColor Cyan
Write-Host ""
Write-Host "7. Click 'Create Service'" -ForegroundColor White

Write-Host ""
Write-Host "✅ After creating the service, run: .\scripts\check-backend-status.ps1" -ForegroundColor Green 