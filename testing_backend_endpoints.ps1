Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "TESTING BACKEND ENDPOINTS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 1. Test health endpoint (no auth required)
Write-Host "1. Testing health endpoint..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/api/health" -Method GET
    Write-Host "   ✓ Health check passed" -ForegroundColor Green
    Write-Host "   Response: $health" -ForegroundColor White
} catch {
    Write-Host "   ✗ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Test if login endpoint exists
Write-Host ""
Write-Host "2. Testing login endpoint (should fail without credentials)..." -ForegroundColor Yellow
try {
    $test = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST
} catch {
    Write-Host "   ✓ Endpoint exists (error is expected)" -ForegroundColor Green
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor White
}

# 3. Try login with detailed error handling
Write-Host ""
Write-Host "3. Testing login with admin credentials..." -ForegroundColor Yellow

$loginBody = @{
    username = "admin"
    password = "admin123"
} | ConvertTo-Json

Write-Host "   Request body: $loginBody" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod `
        -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -Body $loginBody `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host ""
    Write-Host "   ✓✓✓ LOGIN SUCCESSFUL ✓✓✓" -ForegroundColor Green
    Write-Host ""
    Write-Host "   Token: $($response.token.Substring(0, 50))..." -ForegroundColor Cyan
    Write-Host "   Username: $($response.username)" -ForegroundColor Cyan
    Write-Host "   Email: $($response.email)" -ForegroundColor Cyan
    Write-Host "   Role: $($response.role)" -ForegroundColor Cyan
    
} catch {
    Write-Host ""
    Write-Host "   ✗ Login failed!" -ForegroundColor Red
    Write-Host "   Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    # Try to get response body
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Response: $responseBody" -ForegroundColor Yellow
    }
}

# 4. Check backend logs for errors
Write-Host ""
Write-Host "4. Check backend terminal for any errors" -ForegroundColor Yellow
Write-Host "   Look for authentication errors or exceptions" -ForegroundColor White