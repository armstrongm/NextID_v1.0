Write-Host "====================================" -ForegroundColor Cyan
Write-Host "IAM Application Status" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

docker-compose ps

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Health Checks" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Checking Backend Health..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/actuator/health" -UseBasicParsing
    Write-Host $response.Content -ForegroundColor Green
} catch {
    Write-Host "Backend not responding" -ForegroundColor Red
}

Write-Host ""
Write-Host "Checking Frontend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -Method Head
    Write-Host "Frontend Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "Frontend not responding" -ForegroundColor Red
}

Write-Host ""
Write-Host "Checking Database..." -ForegroundColor Yellow
docker-compose exec -T postgres pg_isready -U iam_user

Write-Host ""