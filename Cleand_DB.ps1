Write-Host "=== NUCLEAR RESET - DESTROYING EVERYTHING ===" -ForegroundColor Red
Write-Host ""

# 1. STOP ALL IAM-RELATED CONTAINERS
Write-Host "1. Stopping ALL iam containers..." -ForegroundColor Yellow
docker stop iam-postgres iam-backend iam-frontend 2>$null
docker rm iam-postgres iam-backend iam-frontend 2>$null

# 2. REMOVE ALL VOLUMES (FORCE)
Write-Host "2. Removing ALL volumes..." -ForegroundColor Yellow
docker volume rm iam-postgres-data -f 2>$null
docker volume rm iam-backend-logs -f 2>$null
docker volume rm nextid_postgres_data -f 2>$null
docker volume rm nextid_backend_logs -f 2>$null

# 3. LIST ALL VOLUMES TO VERIFY
Write-Host "3. Remaining volumes:" -ForegroundColor Cyan
docker volume ls | Select-String "iam"

# 4. PRUNE EVERYTHING
Write-Host "4. Pruning unused volumes..." -ForegroundColor Yellow
docker volume prune -f

Write-Host ""
Write-Host "✓ Complete cleanup done!" -ForegroundColor Green
Write-Host ""