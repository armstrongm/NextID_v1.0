cd C:\myNextJsProject\nextID

Write-Host "Stopping all containers..." -ForegroundColor Yellow
docker-compose down -v

Write-Host "`nRebuilding backend..." -ForegroundColor Yellow
cd backend
mvn clean package -DskipTests
cd ..

Write-Host "`nStarting database..." -ForegroundColor Yellow
docker-compose up -d postgres

Write-Host "`nWaiting for database to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "`nStarting backend..." -ForegroundColor Yellow
docker-compose up -d backend

Write-Host "`nWaiting for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

Write-Host "`nChecking backend logs..." -ForegroundColor Yellow
docker logs iam-backend --tail 50

Write-Host "`nTesting backend health..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/api/health" -ErrorAction Stop
    Write-Host "✓ Backend is healthy!" -ForegroundColor Green
} catch {
    Write-Host "✗ Backend is not responding" -ForegroundColor Red
    Write-Host "Check logs with: docker logs iam-backend" -ForegroundColor Yellow
}

Write-Host "`nTesting admin login..." -ForegroundColor Yellow
try {
    $loginBody = @{
        username = "admin"
        password = "admin123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -Body $loginBody `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "✓ Login successful!" -ForegroundColor Green
    Write-Host "Token: $($response.token.Substring(0, 50))..." -ForegroundColor Cyan
} catch {
    Write-Host "✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
}