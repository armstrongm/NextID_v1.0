Write-Host "=====================================" -ForegroundColor Red
Write-Host "CREATING NEW USER IN DATABASE" -ForegroundColor Red
Write-Host "=====================================" -ForegroundColor Red
Write-Host ""

# 1. Create SQL commands
Write-Host "1. Creating brand new database user..." -ForegroundColor Yellow

$sql = @"
DROP DATABASE IF EXISTS freshdb;
DROP USER IF EXISTS freshuser;
CREATE USER freshuser WITH PASSWORD 'fresh123';
CREATE DATABASE freshdb OWNER freshuser;
GRANT ALL PRIVILEGES ON DATABASE freshdb TO freshuser;
"@

# Execute SQL commands
$sql | docker exec -i pgdb psql -U dbuser -d postgres

Write-Host "   ✓ Created freshuser with password fresh123" -ForegroundColor Green

# 2. Test the NEW credentials
Write-Host ""
Write-Host "2. Testing new credentials..." -ForegroundColor Yellow
$env:PGPASSWORD = "fresh123"
$test = docker exec pgdb psql -U freshuser -d freshdb -c "SELECT current_user, current_database();" 2>&1

Write-Host "   Result: $test" -ForegroundColor White

if ($test -match "freshuser") {
    Write-Host "   ✓ NEW credentials work!" -ForegroundColor Green
} else {
    Write-Host "   ✗ Even new credentials don't work!" -ForegroundColor Red
    exit
}

# 3. Update application.properties with NEW credentials
Write-Host ""
Write-Host "3. Updating config with NEW credentials..." -ForegroundColor Yellow

cd C:\myNextJsProject\nextID\backend

$config = @"
spring.datasource.url=jdbc:postgresql://localhost:5432/freshdb
spring.datasource.username=freshuser
spring.datasource.password=fresh123
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
spring.flyway.enabled=false
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.flyway.FlywayAutoConfiguration
jwt.secret=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
jwt.expiration=86400000
server.port=8080
logging.level.org.springframework.jdbc=DEBUG
logging.level.org.springframework.boot.autoconfigure=DEBUG
"@

$config | Set-Content "src\main\resources\application.properties" -Encoding ASCII -Force

Write-Host "   ✓ Config updated" -ForegroundColor Green
Write-Host ""
Write-Host "   New config:" -ForegroundColor Cyan
Get-Content "src\main\resources\application.properties"

# 4. Clean and compile
Write-Host ""
Write-Host "4. Clean compile..." -ForegroundColor Yellow
Remove-Item "target" -Recurse -Force -ErrorAction SilentlyContinue
mvn clean compile -DskipTests

# 5. Manually ensure config is in target/classes
Write-Host ""
Write-Host "5. Ensuring config in target/classes..." -ForegroundColor Yellow
if (-not (Test-Path "target\classes\application.properties")) {
    New-Item -Path "target\classes" -ItemType Directory -Force | Out-Null
    Copy-Item "src\main\resources\application.properties" "target\classes\application.properties" -Force
    Write-Host "   ⚠ Manually copied config" -ForegroundColor Yellow
} else {
    Write-Host "   ✓ Config already in target/classes" -ForegroundColor Green
}

# 6. Verify
Write-Host ""
Write-Host "6. Final verification - config in target/classes:" -ForegroundColor Yellow
Get-Content "target\classes\application.properties" | Select-String "fresh"

# 7. Start
Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "STARTING BACKEND" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Database: freshuser/fresh123 @ localhost:5432/freshdb" -ForegroundColor Cyan
Write-Host ""
Write-Host "If this fails with password error for 'dbuser' (old user)," -ForegroundColor Yellow
Write-Host "then something is caching the old config!" -ForegroundColor Yellow
Write-Host ""

mvn spring-boot:run 2>&1 | Tee-Object -FilePath "startup.log"