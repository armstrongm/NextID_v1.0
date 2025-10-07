Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Setting Up Frontend" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Check if frontend directory exists
if (-not (Test-Path "frontend")) {
    Write-Host "ERROR: frontend directory not found!" -ForegroundColor Red
    Write-Host "Run .\complete-setup.ps1 first" -ForegroundColor Yellow
    exit 1
}

Push-Location frontend

# Check if package.json exists
if (-not (Test-Path "package.json")) {
    Write-Host "ERROR: package.json not found!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "npm install failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host ""
Write-Host "Installing Tailwind CSS..." -ForegroundColor Yellow
npm install -D tailwindcss postcss autoprefixer

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Tailwind installation failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host ""
Write-Host "Verifying package-lock.json..." -ForegroundColor Yellow
if (Test-Path "package-lock.json") {
    Write-Host "✓ package-lock.json created" -ForegroundColor Green
} else {
    Write-Host "✗ package-lock.json not found!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host ""
Write-Host "Testing build..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Build test failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Frontend Setup Complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "You can now run: .\build.ps1" -ForegroundColor Cyan