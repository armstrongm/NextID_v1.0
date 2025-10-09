Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "FIXING POSTGRESQL AUTHENTICATION" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 1. Stop current database
Write-Host "1. Removing old database..." -ForegroundColor Yellow
docker stop pgdb 2>$null
docker rm pgdb 2>$null

# 2. Create database with TRUST authentication initially
Write-Host "2. Creating database with trust authentication..." -ForegroundColor Yellow
docker run -d `
  --name pgdb `
  -e POSTGRES_HOST_AUTH_METHOD=trust `
  -e POSTGRES_USER=appuser `
  -e POSTGRES_DB=appdb `
  -p 5432:5432 `
  postgres:15-alpine

Write-Host "   Waiting 20 seconds..." -ForegroundColor Cyan
Start-Sleep -Seconds 20

# 3. Create user with password using trust mode
Write-Host "3. Creating user with password..." -ForegroundColor Yellow
$createUser = @"
CREATE USER appuser WITH PASSWORD 'apppass123';
ALTER DATABASE appdb OWNER TO appuser;
GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;
"@

$createUser | docker exec -i pgdb psql -U appuser -d appdb

# 4. Update pg_hba.conf to use md5 authentication
Write-Host "4. Configuring authentication..." -ForegroundColor Yellow
docker exec pgdb sh -c "echo 'host all all 0.0.0.0/0 md5' >> /var/lib/postgresql/data/pg_hba.conf"

# 5. Reload PostgreSQL
Write-Host "5. Reloading PostgreSQL..." -ForegroundColor Yellow
docker exec pgdb psql -U appuser -d appdb -c "SELECT pg_reload_conf();"

Write-Host "   Waiting 5 seconds..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# 6. Test from INSIDE container
Write-Host "6. Testing from inside container..." -ForegroundColor Yellow
$env:PGPASSWORD = "apppass123"
$testInside = docker exec pgdb psql -U appuser -d appdb -c "SELECT 'Inside works' as test;" 2>&1

if ($testInside -match "Inside works") {
    Write-Host "   ✓ Inside connection works" -ForegroundColor Green
} else {
    Write-Host "   ✗ Inside connection failed!" -ForegroundColor Red
    Write-Host $testInside
}

# 7. Test JDBC from HOST
Write-Host ""
Write-Host "7. Testing JDBC from host..." -ForegroundColor Yellow

cd C:\myNextJsProject\nextID\backend

$testJava = @"
import java.sql.*;
public class Test {
    public static void main(String[] args) {
        try {
            Connection c = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/appdb",
                "appuser",
                "apppass123"
            );
            System.out.println("SUCCESS");
            c.close();
        } catch (Exception e) {
            System.out.println("FAILED: " + e.getMessage());
        }
    }
}
"@

$testJava | Out-File "Test.java" -Encoding ASCII

$pgJar = Get-ChildItem "$env:USERPROFILE\.m2\repository\org\postgresql\postgresql" -Recurse -Filter "*.jar" | Where-Object { $_.Name -notlike "*-sources.jar" } | Select-Object -First 1

javac Test.java 2>$null
$jdbcResult = java -cp ".;$($pgJar.FullName)" Test

Write-Host "   Result: $jdbcResult" -ForegroundColor White

if ($jdbcResult -match "SUCCESS") {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "✓✓✓ JDBC TEST PASSED ✓✓✓" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Database is now accessible from host!" -ForegroundColor Cyan
    Write-Host ""
    
    # 8. Update Spring Boot config
    Write-Host "8. Updating Spring Boot config..." -ForegroundColor Yellow
    
    $config = @"
spring.datasource.url=jdbc:postgresql://localhost:5432/appdb
spring.datasource.username=appuser
spring.datasource.password=apppass123
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.flyway.enabled=false
jwt.secret=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
jwt.expiration=86400000
server.port=8080
"@

    $config | Set-Content "src\main\resources\application.properties" -Encoding ASCII -Force
    
    Write-Host "   ✓ Config updated" -ForegroundColor Green
    
    # 9. Build
    Write-Host ""
    Write-Host "9. Building..." -ForegroundColor Yellow
    mvn clean compile -DskipTests -q
    Copy-Item "src\main\resources\application.properties" "target\classes\application.properties" -Force
    
    # 10. Start Spring Boot
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "STARTING SPRING BOOT" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Credentials: appuser / apppass123" -ForegroundColor Cyan
    Write-Host "Database: appdb @ localhost:5432" -ForegroundColor Cyan
    Write-Host ""
    
    mvn spring-boot:run
    
} else {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "✗✗✗ JDBC TEST STILL FAILED ✗✗✗" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "The issue is with Docker/PostgreSQL networking." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Try this manual test:" -ForegroundColor Cyan
    Write-Host '  docker exec -it pgdb psql -U appuser -d appdb -c "SELECT 1;"' -ForegroundColor White
    Write-Host ""
    Write-Host "If that works but JDBC fails, it might be:" -ForegroundColor Yellow
    Write-Host "  - Windows Firewall blocking localhost:5432" -ForegroundColor White
    Write-Host "  - Antivirus blocking Java connections" -ForegroundColor White
    Write-Host "  - Docker Desktop networking issue" -ForegroundColor White
}