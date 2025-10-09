cd C:\myNextJsProject\nextID

Write-Host "Stopping containers..." -ForegroundColor Yellow
docker-compose down -v

Write-Host "`nCleaning backend..." -ForegroundColor Yellow
cd backend
Remove-Item -Path "target" -Recurse -Force -ErrorAction SilentlyContinue
mvn clean package -DskipTests
cd ..

Write-Host "`nStarting database..." -ForegroundColor Yellow
docker-compose up -d postgres

Write-Host "`nWaiting for database..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "`nStarting backend..." -ForegroundColor Yellow
docker-compose up -d backend

Write-Host "`nWaiting for backend to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

Write-Host "`nChecking backend logs..." -ForegroundColor Cyan
docker logs iam-backend --tail 100