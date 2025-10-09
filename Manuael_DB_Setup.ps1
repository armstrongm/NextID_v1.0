cd C:\myNextJsProject\nextID

Write-Host "=== CREATING FRESH DATABASE ===" -ForegroundColor Cyan
Write-Host ""

# DEFINE PASSWORD (change this if you want)
$DB_PASS = "BTlab!12345678"

Write-Host "Using password: $DB_PASS" -ForegroundColor Green
Write-Host ""

# 1. CREATE POSTGRES CONTAINER MANUALLY
Write-Host "1. Creating PostgreSQL container..." -ForegroundColor Yellow
docker run -d `
  --name iam-postgres `
  -e POSTGRES_DB=iam_db `
  -e POSTGRES_USER=iam_user `
  -e POSTGRES_PASSWORD=$DB_PASS `
  -p 5432:5432 `
  -v iam-postgres-data:/var/lib/postgresql/data `
  postgres:15-alpine

Write-Host "   Waiting for database to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 15

# 2. TEST CONNECTION
Write-Host "2. Testing database connection..." -ForegroundColor Yellow
$env:PGPASSWORD = $DB_PASS
$test = docker exec iam-postgres psql -U iam_user -d iam_db -c "SELECT 'Connection successful!' as status;" 2>&1

if ($test -match "Connection successful") {
    Write-Host "   ✓ Database is accessible!" -ForegroundColor Green
    
    # 3. CREATE SCHEMA
    Write-Host "3. Creating database schema..." -ForegroundColor Yellow
    
    $sql = @"
DROP TABLE IF EXISTS group_membership CASCADE;
DROP TABLE IF EXISTS ad_accounts CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS auth_users CASCADE;

CREATE TABLE auth_users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL,
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(50) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE groups (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ad_accounts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    sam_account_name VARCHAR(255) NOT NULL,
    distinguished_name VARCHAR(500) NOT NULL,
    user_principal_name VARCHAR(255),
    ad_guid VARCHAR(255) UNIQUE,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    last_error TEXT,
    retry_required BOOLEAN DEFAULT false,
    provisioned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE group_membership (
    user_id BIGINT NOT NULL,
    group_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, group_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
);

INSERT INTO auth_users (username, password_hash, email, role, enabled) 
VALUES ('admin', '\$2a\$10\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@iam.local', 'ADMIN', true);
"@
    
    $sql | docker exec -i iam-postgres psql -U iam_user -d iam_db
    
    # 4. VERIFY TABLES
    Write-Host "4. Verifying tables..." -ForegroundColor Yellow
    $tables = docker exec iam-postgres psql -U iam_user -d iam_db -c "\dt"
    Write-Host $tables
    
    # 5. VERIFY ADMIN USER
    Write-Host "5. Verifying admin user..." -ForegroundColor Yellow
    $adminCheck = docker exec iam-postgres psql -U iam_user -d iam_db -c "SELECT username, email FROM auth_users;"
    Write-Host $adminCheck
    
    if ($adminCheck -match "admin") {
        Write-Host "   ✓ Admin user exists!" -ForegroundColor Green
        
        # 6. UPDATE APPLICATION.PROPERTIES
        Write-Host "6. Updating application.properties..." -ForegroundColor Yellow
        
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        $props = @"
spring.application.name=iam-service
spring.datasource.url=jdbc:postgresql://localhost:5432/iam_db
spring.datasource.username=iam_user
spring.datasource.password=$DB_PASS
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.show-sql=true
spring.flyway.enabled=false
jwt.secret=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
jwt.expiration=86400000
server.port=8080
logging.level.com.company.iam=INFO
"@
        [System.IO.File]::WriteAllText("backend\src\main\resources\application.properties", $props, $utf8NoBom)
        
        # Remove any YAML files
        Remove-Item "backend\src\main\resources\*.yml" -Force -ErrorAction SilentlyContinue
        Remove-Item "backend\src\main\resources\*.yaml" -Force -ErrorAction SilentlyContinue
        
        Write-Host "   ✓ Configuration updated!" -ForegroundColor Green
        
        # 7. SHOW FINAL SUMMARY
        Write-Host ""
        Write-Host "=== SETUP COMPLETE ===" -ForegroundColor Green
        Write-Host ""
        Write-Host "Database is ready!" -ForegroundColor Cyan
        Write-Host "  Host: localhost:5432" -ForegroundColor White
        Write-Host "  Database: iam_db" -ForegroundColor White
        Write-Host "  Username: iam_user" -ForegroundColor White
        Write-Host "  Password: $DB_PASS" -ForegroundColor White
        Write-Host ""
        Write-Host "Admin credentials:" -ForegroundColor Cyan
        Write-Host "  Username: admin" -ForegroundColor White
        Write-Host "  Password: admin123" -ForegroundColor White
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "  1. cd backend" -ForegroundColor White
        Write-Host "  2. mvn clean package -DskipTests" -ForegroundColor White
        Write-Host "  3. mvn spring-boot:run" -ForegroundColor White
        Write-Host ""
        
        # Ask if user wants to start backend now
        $response = Read-Host "Start backend now? (y/n)"
        if ($response -eq 'y') {
            cd backend
            mvn clean package -DskipTests
            mvn spring-boot:run
        }
        
    } else {
        Write-Host "   ✗ Failed to create admin user!" -ForegroundColor Red
    }
    
} else {
    Write-Host "   ✗ Database connection FAILED!" -ForegroundColor Red
    Write-Host "   Error: $test" -ForegroundColor Red
    Write-Host ""
    Write-Host "Debug: Check container logs" -ForegroundColor Yellow
    docker logs iam-postgres --tail 20
}