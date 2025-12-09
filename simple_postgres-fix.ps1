Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "SIMPLE POSTGRESQL FIX" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 1. Stop and remove old container
Write-Host "1. Removing old database..." -ForegroundColor Yellow
docker stop pgdb 2>$null
docker rm pgdb 2>$null
docker volume prune -f

# 2. Start with MD5 auth and simple password
Write-Host "2. Starting database with md5 authentication..." -ForegroundColor Yellow
docker run -d `
  --name pgdb `
  -e POSTGRES_USER=simpleuser `
  -e POSTGRES_PASSWORD=simplepass `
  -e POSTGRES_DB=simpledb `
  -e POSTGRES_HOST_AUTH_METHOD=md5 `
  -p 5432:5432 `
  postgres:15-alpine -c listen_addresses='*'

Write-Host "   Waiting 25 seconds..." -ForegroundColor Cyan
Start-Sleep -Seconds 25

# 3. Test from inside container
Write-Host ""
Write-Host "3. Testing from inside container..." -ForegroundColor Yellow
$env:PGPASSWORD = "simplepass"
$testInside = docker exec pgdb psql -U simpleuser -d simpledb -c "SELECT 'Works' as test;" 2>&1

if ($testInside -match "Works") {
    Write-Host "   ✓ Inside connection works" -ForegroundColor Green
} else {
    Write-Host "   ✗ Inside failed!" -ForegroundColor Red
    Write-Host $testInside
    exit
}

# 4. Test JDBC from HOST
Write-Host ""
Write-Host "4. Testing JDBC from host..." -ForegroundColor Yellow

cd C:\myNextJsProject\nextID\backend

$testJava = @"
import java.sql.*;
public class QuickTest {
    public static void main(String[] args) {
        try {
            Connection c = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/simpledb",
                "simpleuser",
                "simplepass"
            );
            System.out.println("SUCCESS");
            c.close();
            System.exit(0);
        } catch (Exception e) {
            System.out.println("FAILED: " + e.getMessage());
            System.exit(1);
        }
    }
}
"@

$testJava | Out-File "QuickTest.java" -Encoding ASCII

$pgJar = Get-ChildItem "$env:USERPROFILE\.m2\repository\org\postgresql\postgresql" -Recurse -Filter "*.jar" | Where-Object { $_.Name -notlike "*-sources.jar" } | Select-Object -First 1

javac QuickTest.java 2>$null
java -cp ".;$($pgJar.FullName)" QuickTest

$jdbcResult = $LASTEXITCODE

if ($jdbcResult -eq 0) {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "✓✓✓ JDBC TEST PASSED ✓✓✓" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    
    # Update Spring Boot config
    Write-Host "5. Updating Spring Boot config..." -ForegroundColor Yellow
    
    $config = @"
spring.datasource.url=jdbc:postgresql://localhost:5432/simpledb
spring.datasource.username=simpleuser
spring.datasource.password=simplepass
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
    
    # Build
    Write-Host "6. Building..." -ForegroundColor Yellow
    mvn clean compile -DskipTests -q
    Copy-Item "src\main\resources\application.properties" "target\classes\application.properties" -Force
    
    # Start
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "STARTING SPRING BOOT" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Database: simpleuser/simplepass @ localhost:5432/simpledb" -ForegroundColor Cyan
    Write-Host ""
    
    mvn spring-boot:run
    
} else {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "✗✗✗ JDBC STILL FAILS ✗✗✗" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "This means Docker networking or Windows firewall is blocking connections." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Try running Docker Desktop as administrator" -ForegroundColor Cyan
    Write-Host "Or check Windows Firewall settings for Docker" -ForegroundColor Cyan
}