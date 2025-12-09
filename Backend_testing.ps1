Write-Host "Testing backend..." -ForegroundColor Cyan
Write-Host ""

# Test health
Write-Host "1. Health check:" -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/api/health" -Method GET
    Write-Host "   ✓ Backend is up!" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Cannot reach backend" -ForegroundColor Red
}

# Test login
Write-Host ""
Write-Host "2. Testing login:" -ForegroundColor Yellow

$body = @{
    username = "admin"
    password = "admin123"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod `
        -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -Body $body `
        -ContentType "application/json"
    
    Write-Host "   ✓✓✓ LOGIN SUCCESSFUL! ✓✓✓" -ForegroundColor Green
    Write-Host ""
    Write-Host "   Token: $($response.token.Substring(0, 50))..." -ForegroundColor Cyan
    Write-Host "   Username: $($response.username)" -ForegroundColor Cyan
    Write-Host "   Email: $($response.email)" -ForegroundColor Cyan
    Write-Host "   Role: $($response.role)" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test what the users API actually returns
$token = $response.token  # Use the token from login

Invoke-RestMethod -Uri "http://localhost:8080/api/users" `
  -Method GET `
  -Headers @{Authorization="Bearer $token"}