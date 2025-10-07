Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Checking Port 5432" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Checking what's using port 5432..." -ForegroundColor Yellow
$process = Get-NetTCPConnection -LocalPort 5432 -ErrorAction SilentlyContinue

if ($process) {
    Write-Host ""
    Write-Host "Port 5432 is in use by:" -ForegroundColor Red
    $process | ForEach-Object {
        $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        if ($proc) {
            Write-Host "  Process: $($proc.ProcessName)" -ForegroundColor Yellow
            Write-Host "  PID: $($proc.Id)" -ForegroundColor Yellow
            Write-Host "  Path: $($proc.Path)" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "1. Stop PostgreSQL service: .\stop-postgres.ps1" -ForegroundColor White
    Write-Host "2. Use different port: .\change-port.ps1" -ForegroundColor White
    Write-Host "3. Stop Docker containers: .\cleanup-containers.ps1" -ForegroundColor White
} else {
    Write-Host "Port 5432 is available" -ForegroundColor Green
    Write-Host ""
    Write-Host "Checking for Docker containers on 5432..." -ForegroundColor Yellow
    
    $dockerContainers = docker ps --format "{{.Names}}" --filter "publish=5432"
    if ($dockerContainers) {
        Write-Host "Found Docker containers using port 5432:" -ForegroundColor Red
        $dockerContainers | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
        Write-Host ""
        Write-Host "Run: .\cleanup-containers.ps1" -ForegroundColor Cyan
    } else {
        Write-Host "No issues found with port 5432" -ForegroundColor Green
    }
}