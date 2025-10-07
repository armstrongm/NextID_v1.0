param(
    [string]$Service = ""
)

Write-Host "====================================" -ForegroundColor Cyan

if ($Service -eq "") {
    Write-Host "IAM Application Logs" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Ctrl+C to exit" -ForegroundColor Yellow
    Write-Host ""
    docker-compose logs -f
} else {
    Write-Host "$Service Logs" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Ctrl+C to exit" -ForegroundColor Yellow
    Write-Host ""
    docker-compose logs -f $Service
}