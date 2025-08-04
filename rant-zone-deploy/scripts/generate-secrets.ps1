# PowerShell script to generate secure secrets

Write-Host "🔐 Generating Secure Secrets" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host ""

# Generate JWT Secret (256-bit random string)
$jwtSecret = -join ((33..126) | Get-Random -Count 64 | ForEach-Object {[char]$_})
Write-Host "JWT_SECRET:" -ForegroundColor Yellow
Write-Host $jwtSecret
Write-Host ""

# Generate Encryption Key (base64-like string)
$encryptionKey = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((1..32 | ForEach-Object {Get-Random -Maximum 256})))
Write-Host "ENCRYPTION_KEY:" -ForegroundColor Yellow
Write-Host $encryptionKey
Write-Host ""

Write-Host "📋 Copy these values to your auth-config.json file:" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "`"jwt_secret`": `"$jwtSecret`","
Write-Host "`"encryption_key`": `"$encryptionKey`","
Write-Host "`"bcrypt_rounds`": 12"
Write-Host ""

Write-Host "⚠️  Keep these secrets secure!" -ForegroundColor Red 