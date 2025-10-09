cd C:\myNextJsProject\nextID\backend

# Clean everything
Remove-Item -Path "target" -Recurse -Force -ErrorAction SilentlyContinue
mvn clean

# Make sure database is running
docker-compose up -d postgres
Write-Host "Waiting for database..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test database connection
try {
    docker exec -it iam-postgres psql -U iam_user -d iam_db -c "SELECT 1;"
    Write-Host "✓ Database connection OK" -ForegroundColor Green
} catch {
    Write-Host "✗ Database connection failed!" -ForegroundColor Red
    exit
}

# Build
mvn package -DskipTests

# Run locally with verbose output
Write-Host "`nStarting backend..." -ForegroundColor Cyan
mvn spring-boot:run