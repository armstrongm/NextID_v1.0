Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Full Stack Deployment" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Create all backend files
#Write-Host "Step 1: Creating Backend Implementation..." -ForegroundColor Yellow
#& .\create-jwt-implementation.ps1
#& .\create-user-service.ps1
#& .\create-user-dto-service.ps1
#& .\create-services-impl.ps1
#& .\create-controllers.ps1

# Step 2: Create frontend API integration
Write-Host ""
Write-Host "Step 2: Creating Frontend API Integration..." -ForegroundColor Yellow
#& .\create-frontend-api.ps1

# Step 3: Build backend
Write-Host ""
Write-Host "Step 3: Building Backend..." -ForegroundColor Yellow
Push-Location backend
mvn clean package -DskipTests
if ($LASTEXITCODE -ne 0) {
    Write-Host "Backend build failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location
Write-Host "  ✓ Backend built successfully" -ForegroundColor Green

# Step 4: Build frontend
Write-Host ""
Write-Host "Step 4: Building Frontend..." -ForegroundColor Yellow
Push-Location frontend
npm install
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Frontend build failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location
Write-Host "  ✓ Frontend built successfully" -ForegroundColor Green

# Step 5: Build Docker images
Write-Host ""
Write-Host "Step 5: Building Docker Images..." -ForegroundColor Yellow
docker-compose build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Docker images built successfully" -ForegroundColor Green

# Step 6: Start containers
Write-Host ""
Write-Host "Step 6: Starting Containers..." -ForegroundColor Yellow
docker-compose down
docker-compose up -d

Write-Host ""
Write-Host "Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Step 7: Check status
Write-Host ""
Write-Host "Step 7: Checking Service Status..." -ForegroundColor Yellow
docker-compose ps

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Access your application:" -ForegroundColor Cyan
Write-Host "  Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "  Backend:  http://localhost:8080/api" -ForegroundColor White
Write-Host "  Health:   http://localhost:8080/api/health" -ForegroundColor White
Write-Host ""
Write-Host "Test Login:" -ForegroundColor Cyan
Write-Host "  Username: admin" -ForegroundColor White
Write-Host "  Password: admin123" -ForegroundColor White
Write-Host ""
Write-Host "Check logs: docker-compose logs -f" -ForegroundColor Yellow