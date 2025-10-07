Write-Host "====================================" -ForegroundColor Red
Write-Host "WARNING: This will remove ALL data!" -ForegroundColor Red
Write-Host "====================================" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Are you sure you want to clean all data? (y/N)"

if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Stopping and removing containers..." -ForegroundColor Yellow
docker-compose down -v

Write-Host ""
Write-Host "Removing volumes..." -ForegroundColor Yellow
docker volume rm iam-postgres-data 2>$null
docker volume rm iam-backend-logs 2>$null
docker volume rm iam-pgadmin-data 2>$null

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Clean complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green