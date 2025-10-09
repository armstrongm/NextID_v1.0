cd C:\myNextJsProject\nextID

Write-Host "=== COMPLETE RESET ===" -ForegroundColor Cyan
Write-Host ""

# 1. Stop everything
Write-Host "1. Stopping containers..." -ForegroundColor Yellow
docker-compose down -v
docker volume prune -f

# 2. Set consistent password
$DB_PASSWORD = "SecurePassword123!"
Write-Host "2. Using password: $DB_PASSWORD" -ForegroundColor Yellow

# 3. Update .env
Write-Host "3. Updating .env..." -ForegroundColor Yellow
(Get-Content ".env") -replace "DB_PASSWORD=.*", "DB_PASSWORD=$DB_PASSWORD" | Set-Content ".env"

# 4. Update application.properties
Write-Host "4. Updating application.properties..." -ForegroundColor Yellow
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$props = Get-Content "backend\src\main\resources\application.properties" -Raw
$props = $props -replace "spring.datasource.password=.*", "spring.datasource.password=$DB_PASSWORD"
[System.IO.File]::WriteAllText("backend\src\main\resources\application.properties", $props, $utf8NoBom)

# 5. Start database
Write-Host "5. Starting fresh database..." -ForegroundColor Yellow
docker-compose up -d postgres
Start-Sleep -Seconds 15

# 6. Test connection
Write-Host "6. Testing database connection..." -ForegroundColor Yellow
$env:PGPASSWORD = $DB_PASSWORD
$result = docker exec iam-postgres psql -U iam_user -d iam_db -c "SELECT 1;" 2>&1

if ($result -match "1 row") {
    Write-Host "   ✓ Database connection OK!" -ForegroundColor Green
    
    # 7. Build and run backend
    Write-Host "7. Building backend..." -ForegroundColor Yellow
    cd backend
    mvn clean package -DskipTests
    
    Write-Host "8. Starting backend..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "mvn spring-boot:run"
    
    Write-Host ""
    Write-Host "=== SETUP COMPLETE ===" -ForegroundColor Green
    Write-Host "Backend should be starting in new window..." -ForegroundColor Cyan
    Write-Host "Wait for: 'Started IamApplication'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Then test with:" -ForegroundColor Yellow
    Write-Host "  curl http://localhost:8080/api/health" -ForegroundColor White
    
} else {
    Write-Host "   ✗ Database connection FAILED!" -ForegroundColor Red
    Write-Host "   Error: $result" -ForegroundColor Red
}