Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Cleaning Up Existing Containers" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Stopping all IAM containers..." -ForegroundColor Yellow
docker-compose down

Write-Host ""
Write-Host "Checking for any remaining IAM containers..." -ForegroundColor Yellow
$containers = docker ps -a --filter "name=iam-" --format "{{.Names}}"

if ($containers) {
    Write-Host "Found containers:" -ForegroundColor Yellow
    $containers | ForEach-Object { Write-Host "  - $_" -ForegroundColor Cyan }
    
    Write-Host ""
    Write-Host "Removing containers..." -ForegroundColor Yellow
    docker rm -f $containers
    Write-Host "Done" -ForegroundColor Green
} else {
    Write-Host "No IAM containers found" -ForegroundColor Green
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Cleanup Complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Now run: .\start.ps1" -ForegroundColor Cyan