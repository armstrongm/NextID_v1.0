Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Fixing Port 5432 Issue" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop any existing Docker containers
Write-Host "Step 1: Stopping existing Docker containers..." -ForegroundColor Yellow
docker-compose down 2>$null

# Remove any stopped IAM containers
$containers = docker ps -a --filter "name=iam-" --format "{{.Names}}" 2>$null
if ($containers) {
    Write-Host "Removing old containers..." -ForegroundColor Yellow
    docker rm -f $containers 2>$null
}
Write-Host "  Done" -ForegroundColor Green

# Step 2: Check if port is still in use
Write-Host ""
Write-Host "Step 2: Checking port 5432..." -ForegroundColor Yellow
$portInUse = Get-NetTCPConnection -LocalPort 5432 -ErrorAction SilentlyContinue

if ($portInUse) {
    Write-Host "  Port 5432 is still in use" -ForegroundColor Red
    
    $proc = Get-Process -Id $portInUse[0].OwningProcess -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host "  Used by: $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Choose an option:" -ForegroundColor Cyan
    Write-Host "1. Change Docker PostgreSQL to port 5433 (Recommended)" -ForegroundColor White
    Write-Host "2. Stop local PostgreSQL service (Requires Admin)" -ForegroundColor White
    Write-Host "3. Exit and fix manually" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Enter choice (1-3)"
    
    if ($choice -eq "1") {
        Write-Host ""
        Write-Host "Changing to port 5433..." -ForegroundColor Yellow
        
        if (Test-Path ".env") {
            $envContent = Get-Content ".env" -Raw
            $envContent = $envContent -replace 'DB_PORT=5432', 'DB_PORT=5433'
            
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText(".env", $envContent, $utf8NoBom)
            
            Write-Host "  Updated .env to use port 5433" -ForegroundColor Green
            Write-Host ""
            Write-Host "Starting application on port 5433..." -ForegroundColor Yellow
            & .\start.ps1
        }
    }
    elseif ($choice -eq "2") {
        Write-Host ""
        Write-Host "Please run PowerShell as Administrator and execute:" -ForegroundColor Yellow
        Write-Host "  .\stop-postgres.ps1" -ForegroundColor Cyan
        Write-Host "Then run: .\start.ps1" -ForegroundColor Cyan
    }
    else {
        Write-Host ""
        Write-Host "Exiting..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Manual fix options:" -ForegroundColor Cyan
        Write-Host "- Stop PostgreSQL: net stop postgresql-x64-XX" -ForegroundColor White
        Write-Host "- Use different port: Edit .env and change DB_PORT" -ForegroundColor White
        Write-Host "- Kill process: taskkill /PID <PID> /F" -ForegroundColor White
    }
} else {
    Write-Host "  Port 5432 is available" -ForegroundColor Green
    Write-Host ""
    Write-Host "Starting application..." -ForegroundColor Yellow
    & .\start.ps1
}