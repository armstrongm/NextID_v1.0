Write-Host "====================================" -ForegroundColor Cyan
Write-Host "IAM Application Diagnostics" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "1. Checking Docker..." -ForegroundColor Yellow
$dockerRunning = docker info 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Docker is running" -ForegroundColor Green
} else {
    Write-Host "   ✗ Docker is not running!" -ForegroundColor Red
    Write-Host "   Start Docker Desktop and try again" -ForegroundColor Yellow
    exit 1
}

# Check container status
Write-Host ""
Write-Host "2. Checking containers..." -ForegroundColor Yellow
Write-Host ""
docker-compose ps

Write-Host ""
Write-Host "3. Detailed container status..." -ForegroundColor Yellow
$containers = @("iam-frontend", "iam-backend", "iam-postgres")

foreach ($container in $containers) {
    $status = docker inspect --format='{{.State.Status}}' $container 2>$null
    $health = docker inspect --format='{{.State.Health.Status}}' $container 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   $container`: " -NoNewline -ForegroundColor Cyan
        
        if ($status -eq "running") {
            Write-Host "Running" -NoNewline -ForegroundColor Green
            if ($health) {
                Write-Host " (Health: $health)" -ForegroundColor Gray
            } else {
                Write-Host ""
            }
        } else {
            Write-Host "$status" -ForegroundColor Red
        }
    } else {
        Write-Host "   $container`: Not found" -ForegroundColor Red
    }
}

# Check ports
Write-Host ""
Write-Host "4. Checking port bindings..." -ForegroundColor Yellow
$ports = docker ps --format "table {{.Names}}\t{{.Ports}}" --filter "name=iam-"
if ($ports) {
    Write-Host $ports
} else {
    Write-Host "   No containers running!" -ForegroundColor Red
}

# Check frontend logs
Write-Host ""
Write-Host "5. Frontend container logs (last 20 lines)..." -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Gray
docker logs iam-frontend --tail 20 2>&1
Write-Host "-------------------------------------------" -ForegroundColor Gray

# Test connections
Write-Host ""
Write-Host "6. Testing connections..." -ForegroundColor Yellow

$tests = @(
    @{Port=3000; Name="Frontend"; Container="iam-frontend"},
    @{Port=8080; Name="Backend"; Container="iam-backend"},
    @{Port=5432; Name="Database"; Container="iam-postgres"}
)

foreach ($test in $tests) {
    Write-Host "   Testing localhost:$($test.Port) ($($test.Name))... " -NoNewline
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$($test.Port)" -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
        Write-Host "✓ Reachable" -ForegroundColor Green
    } catch {
        Write-Host "✗ Unreachable" -ForegroundColor Red
        
        # Check if container is running
        $running = docker inspect --format='{{.State.Status}}' $test.Container 2>$null
        if ($running -eq "running") {
            Write-Host "      Container is running but port not accessible" -ForegroundColor Yellow
        } else {
            Write-Host "      Container is not running" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Recommendations:" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

$frontendRunning = docker inspect --format='{{.State.Status}}' iam-frontend 2>$null

if ($frontendRunning -ne "running") {
    Write-Host "Frontend container is not running!" -ForegroundColor Red
    Write-Host "Run: docker-compose logs frontend" -ForegroundColor Yellow
    Write-Host "Then: .\restart.ps1" -ForegroundColor Yellow
} else {
    Write-Host "Frontend container is running but port 3000 not accessible" -ForegroundColor Yellow
    Write-Host "Run: .\fix-frontend-port.ps1" -ForegroundColor Yellow
}