Write-Host ""
Write-Host "=== STARTING FRESH DATABASE ===" -ForegroundColor Cyan
Write-Host ""

$PASSWORD = "mypass123"

docker run -d `
  --name fresh-postgres `
  --rm `
  -e POSTGRES_USER=myuser `
  -e POSTGRES_PASSWORD=$PASSWORD `
  -e POSTGRES_DB=mydb `
  -p 5432:5432 `
  postgres:15-alpine

Write-Host "Waiting 20 seconds for database to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Test connection
Write-Host "Testing connection..." -ForegroundColor Yellow
$env:PGPASSWORD = $PASSWORD
$test = docker exec fresh-postgres psql -U myuser -d mydb -c "SELECT version();" 2>&1

if ($test -match "PostgreSQL") {
    Write-Host "✓ Database is working!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Connection details:" -ForegroundColor Cyan
    Write-Host "  URL: jdbc:postgresql://localhost:5432/mydb" -ForegroundColor White
    Write-Host "  Username: myuser" -ForegroundColor White
    Write-Host "  Password: $PASSWORD" -ForegroundColor White
} else {
    Write-Host "✗ Database test failed!" -ForegroundColor Red
    Write-Host $test
    exit
}