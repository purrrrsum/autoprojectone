# Project WebApp Verification Script
Write-Host "=== Project WebApp Verification ===" -ForegroundColor Green
Write-Host ""

# Check if all required files exist
Write-Host "Step 1: Checking project structure..." -ForegroundColor Yellow

$requiredFiles = @(
    "package.json",
    "README.md",
    "PROJECT_SUMMARY.md",
    ".gitignore",
    "LICENSE",
    "docker-compose.yml",
    "buildspec-optimized.yml",
    "task-definition.json",
    "backend/package.json",
    "backend/Dockerfile.aws",
    "backend/env.example",
    "frontend/package.json",
    "frontend/Dockerfile",
    "frontend/env.example"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file" -ForegroundColor Red
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "❌ Missing files: $($missingFiles.Count)" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "   - $file" -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "✅ All required files present" -ForegroundColor Green
}

# Check if Node.js is installed
Write-Host ""
Write-Host "Step 2: Checking Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Node.js version: $nodeVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ Node.js not found" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Node.js not found" -ForegroundColor Red
}

# Check if npm is installed
Write-Host ""
Write-Host "Step 3: Checking npm..." -ForegroundColor Yellow
try {
    $npmVersion = npm --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ npm version: $npmVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ npm not found" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ npm not found" -ForegroundColor Red
}

# Check if Docker is available
Write-Host ""
Write-Host "Step 4: Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker version: $dockerVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker not found or not running" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Docker not found" -ForegroundColor Red
}

# Check if AWS CLI is configured
Write-Host ""
Write-Host "Step 5: Checking AWS CLI..." -ForegroundColor Yellow
try {
    $awsIdentity = aws sts get-caller-identity 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ AWS CLI configured" -ForegroundColor Green
        Write-Host "   Account: $($awsIdentity.Account)" -ForegroundColor Cyan
        Write-Host "   User: $($awsIdentity.Arn)" -ForegroundColor Cyan
    } else {
        Write-Host "❌ AWS CLI not configured" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ AWS CLI not found" -ForegroundColor Red
}

# Check package.json scripts
Write-Host ""
Write-Host "Step 6: Checking package.json scripts..." -ForegroundColor Yellow
try {
    $packageJson = Get-Content "package.json" | ConvertFrom-Json
    $requiredScripts = @("dev", "build", "install:all", "docker:compose", "aws:deploy:complete")
    
    foreach ($script in $requiredScripts) {
        if ($packageJson.scripts.PSObject.Properties.Name -contains $script) {
            Write-Host "✅ npm run $script" -ForegroundColor Green
        } else {
            Write-Host "❌ npm run $script" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ Error reading package.json" -ForegroundColor Red
}

# Check directory structure
Write-Host ""
Write-Host "Step 7: Checking directory structure..." -ForegroundColor Yellow
$requiredDirs = @("backend", "frontend", "scripts", "docs", "infrastructure")
foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        $fileCount = (Get-ChildItem $dir -Recurse -File).Count
        Write-Host "✅ $dir ($fileCount files)" -ForegroundColor Green
    } else {
        Write-Host "❌ $dir" -ForegroundColor Red
    }
}

# Final summary
Write-Host ""
Write-Host "=== Verification Summary ===" -ForegroundColor Green
Write-Host ""

if ($missingFiles.Count -eq 0) {
    Write-Host "🎉 Project verification completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Install dependencies: npm run install:all" -ForegroundColor Cyan
    Write-Host "2. Start development: npm run dev" -ForegroundColor Cyan
    Write-Host "3. Deploy to AWS: npm run aws:deploy:complete" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📚 Documentation available in docs/ directory" -ForegroundColor Cyan
    Write-Host "🛠️ Deployment scripts available in scripts/ directory" -ForegroundColor Cyan
} else {
    Write-Host "⚠️ Project verification completed with issues" -ForegroundColor Yellow
    Write-Host "Please fix the missing files before proceeding" -ForegroundColor Red
}

Write-Host ""
