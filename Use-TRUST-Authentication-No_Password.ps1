Write-Host "=====================================" -ForegroundColor Red
Write-Host "TRUST MODE - NO PASSWORD NEEDED" -ForegroundColor Red
Write-Host "=====================================" -ForegroundColor Red
Write-Host ""

# Stop everything
docker stop pgdb 2>$null
docker rm pgdb 2>$null

# Start with TRUST - no password required
Write-Host "Starting database with TRUST authentication (no password)..." -ForegroundColor Yellow
docker run -d `
  --name pgdb `
  -e POSTGRES_HOST_AUTH_METHOD=trust `
  -e POSTGRES_USER=trustuser `
  -e POSTGRES_DB=trustdb `
  -p 5432:5432 `
  postgres:15-alpine

Write-Host "Waiting 20 seconds..." -ForegroundColor Cyan
Start-Sleep -Seconds 20

# Test from inside
Write-Host ""
Write-Host "Testing from inside..." -ForegroundColor Yellow
docker exec pgdb psql -U trustuser -d trustdb -c "SELECT 'OK' as test;"

# Test JDBC WITHOUT password
Write-Host ""
Write-Host "Testing JDBC from host (no password)..." -ForegroundColor Yellow

cd C:\myNextJsProject\nextID\backend

$testJava = @"
import java.sql.*;
public class TrustTest {
    public static void main(String[] args) {
        try {
            // No password with trust mode
            Connection c = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/trustdb?user=trustuser"
            );
            System.out.println("SUCCESS - Connection works!");
            
            Statement s = c.createStatement();
            ResultSet rs = s.executeQuery("SELECT version()");
            rs.next();
            System.out.println(rs.getString(1).substring(0, 40));
            
            c.close();
            System.exit(0);
        } catch (Exception e) {
            System.out.println("FAILED: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
"@

$testJava | Out-File "TrustTest.java" -Encoding ASCII

$pgJar = Get-ChildItem "$env:USERPROFILE\.m2\repository\org\postgresql\postgresql" -Recurse -Filter "*.jar" | Where-Object { $_.Name -notlike "*-sources.jar" } | Select-Object -First 1

javac TrustTest.java
java -cp ".;$($pgJar.FullName)" TrustTest

$result = $LASTEXITCODE

if ($result -eq 0) {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "SUCCESS - TRUST MODE WORKS!" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "This proves:" -ForegroundColor Cyan
    Write-Host "  - Java CAN connect to PostgreSQL" -ForegroundColor White
    Write-Host "  - Docker networking works" -ForegroundColor White
    Write-Host "  - The problem was authentication method" -ForegroundColor White
    Write-Host ""
    
    # Update Spring Boot to use trust mode
    Write-Host "Updating Spring Boot config for trust mode..." -ForegroundColor Yellow
    
    $config = @"
spring.datasource.url=jdbc:postgresql://localhost:5432/trustdb?user=trustuser
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.flyway.enabled=false
jwt.secret=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
jwt.expiration=86400000
server.port=8080
"@

    $config | Set-Content "src\main\resources\application.properties" -Encoding ASCII
    
    # Build
    mvn clean compile -DskipTests -q
    Copy-Item "src\main\resources\application.properties" "target\classes\application.properties" -Force
    
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "STARTING SPRING BOOT (NO PASSWORD)" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    
    mvn spring-boot:run
    
} else {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "EVEN TRUST MODE FAILED!" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "If trust mode fails, the issue is deeper:" -ForegroundColor Yellow
    Write-Host "  - Docker Desktop may be broken" -ForegroundColor White
    Write-Host "  - Windows Firewall is blocking localhost" -ForegroundColor White
    Write-Host "  - Antivirus is blocking Java" -ForegroundColor White
    Write-Host ""
    Write-Host "Try:" -ForegroundColor Cyan
    Write-Host "  1. Restart Docker Desktop" -ForegroundColor White
    Write-Host "  2. Disable Windows Firewall temporarily" -ForegroundColor White
    Write-Host "  3. Run PowerShell as Administrator" -ForegroundColor White
}