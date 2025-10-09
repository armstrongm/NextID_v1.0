cd C:\myNextJsProject\nextID

Write-Host "`nStarting PostgreSQL..." -ForegroundColor Yellow
docker-compose up -d postgres

Write-Host "Waiting for database to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "`nTesting database connection..." -ForegroundColor Cyan
$testResult = docker exec iam-postgres psql -U iam_user -d iam_db -c "SELECT 1;" 2>&1

if ($testResult -match "1 row") {
    Write-Host "✓ Database connection successful!" -ForegroundColor Green
} else {
    Write-Host "✗ Database connection failed!" -ForegroundColor Red
    Write-Host "Error: $testResult" -ForegroundColor Red
    exit
}