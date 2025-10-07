Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Fixing Tailwind CSS Configuration" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

Push-Location frontend

Write-Host "Uninstalling current Tailwind..." -ForegroundColor Yellow
npm uninstall tailwindcss postcss autoprefixer

Write-Host ""
Write-Host "Installing Tailwind CSS v3 (stable)..." -ForegroundColor Yellow
npm install -D tailwindcss@^3 postcss@^8 autoprefixer@^10

if ($LASTEXITCODE -ne 0) {
    Write-Host "Installation failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host ""
Write-Host "Verifying installation..." -ForegroundColor Yellow
npm list tailwindcss

Write-Host ""
Write-Host "Testing build..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Green
    Write-Host "Tailwind CSS Fixed!" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Build still failing. Check output above." -ForegroundColor Red
}

Pop-Location