Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Building IAM Application Docker Images" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Validate first
Write-Host "Running validation checks..." -ForegroundColor Yellow
& C:\myNextJsProject\nextID\validate.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Validation failed! Please fix errors before building." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Building backend..." -ForegroundColor Yellow
docker build -t iam-backend:latest C:\myNextJsProject\nextID\backend

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error building backend!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "1. Check that backend/pom.xml is complete and valid" -ForegroundColor Yellow
    Write-Host "2. Ensure Java source files are in backend/src/main/java" -ForegroundColor Yellow
    Write-Host "3. Check Docker daemon is running" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Building frontend..." -ForegroundColor Yellow
docker build -t iam-frontend:latest C:\myNextJsProject\nextID\frontend

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error building frontend!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "1. Check that frontend/package.json exists" -ForegroundColor Yellow
    Write-Host "2. Ensure React source files are in frontend/src" -ForegroundColor Yellow
    Write-Host "3. Check Docker daemon is running" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Build complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run .\start.ps1 to start the application" -ForegroundColor White
Write-Host "2. Access frontend at http://localhost:3000" -ForegroundColor White
Write-Host "3. API available at http://localhost:8080/api" -ForegroundColor White