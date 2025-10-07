Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Stopping IAM Application" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

docker-compose down

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error stopping services!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "IAM Application stopped!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green