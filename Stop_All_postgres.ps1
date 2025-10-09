Write-Host "=== STOPPING ALL POSTGRES CONTAINERS ===" -ForegroundColor Cyan
Write-Host ""

# Stop and remove ALL postgres containers
Write-Host "Stopping all postgres containers..." -ForegroundColor Yellow
docker stop $(docker ps -aq --filter ancestor=postgres:15-alpine) 2>$null
docker stop $(docker ps -aq --filter ancestor=postgres:15) 2>$null
docker stop $(docker ps -aq --filter ancestor=postgres:16) 2>$null
docker stop $(docker ps -aq --filter ancestor=postgres) 2>$null

docker rm $(docker ps -aq --filter ancestor=postgres) 2>$null

# Specifically target the ones we saw
docker stop f5b91eb79535 49de6da2e323 7c2b2b36b937 2>$null
docker rm f5b91eb79535 49de6da2e323 7c2b2b36b937 2>$null

# Stop by name
docker stop iam-postgres test-postgres 2>$null
docker rm iam-postgres test-postgres 2>$null

Write-Host "✓ All postgres containers stopped" -ForegroundColor Green
Write-Host ""

# Verify nothing is running
Write-Host "Verifying..." -ForegroundColor Yellow
docker ps -a | Select-String "postgres"

Write-Host ""
Write-Host "Checking port 5432..." -ForegroundColor Yellow
netstat -ano | findstr :5432