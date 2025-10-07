Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Restarting IAM Application" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Stopping services..." -ForegroundColor Yellow
docker-compose down

Write-Host ""
Write-Host "Starting services..." -ForegroundColor Yellow
docker-compose up -d

Write-Host ""
Write-Host "Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host ""
docker-compose ps

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Restart complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green