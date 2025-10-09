Write-Host "=== DIAGNOSTIC REPORT ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check Docker
Write-Host "1. Docker Status:" -ForegroundColor Yellow
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 2. Check Database
Write-Host "`n2. Database Check:" -ForegroundColor Yellow
try {
    docker exec iam-postgres psql -U iam_user -d iam_db -c "SELECT version();" 2>&1
    Write-Host "✓ Database is accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Cannot connect to database" -ForegroundColor Red
}

# 3. Check Port 5432
Write-Host "`n3. Port 5432 Status:" -ForegroundColor Yellow
netstat -ano | findstr :5432

# 4. Check application.properties exists
Write-Host "`n4. Configuration File:" -ForegroundColor Yellow
if (Test-Path "backend\src\main\resources\application.properties") {
    Write-Host "✓ application.properties exists" -ForegroundColor Green
    Write-Host "Database URL:" -ForegroundColor Cyan
    Get-Content "backend\src\main\resources\application.properties" | Select-String "spring.datasource.url"
} else {
    Write-Host "✗ application.properties NOT FOUND" -ForegroundColor Red
}

# 5. Check Entity classes
Write-Host "`n5. Entity Classes:" -ForegroundColor Yellow
$entities = Get-ChildItem "backend\src\main\java\com\company\iam\model" -Filter "*.java"
foreach ($entity in $entities) {
    $hasEntity = Get-Content $entity.FullName | Select-String "@Entity"
    if ($hasEntity) {
        Write-Host "✓ $($entity.Name)" -ForegroundColor Green
    } else {
        Write-Host "✗ $($entity.Name) - Missing @Entity" -ForegroundColor Red
    }
}

# 6. Check Repository classes
Write-Host "`n6. Repository Classes:" -ForegroundColor Yellow
$repos = Get-ChildItem "backend\src\main\java\com\company\iam\repository" -Filter "*.java"
foreach ($repo in $repos) {
    Write-Host "  - $($repo.Name)" -ForegroundColor White
}

Write-Host "`n=== END REPORT ===" -ForegroundColor Cyan