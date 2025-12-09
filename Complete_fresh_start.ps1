Write-Host "=====================================" -ForegroundColor Red
Write-Host "COMPLETE DATABASE RECREATION" -ForegroundColor Red
Write-Host "=====================================" -ForegroundColor Red
Write-Host ""

# 1. Stop and remove EVERYTHING
Write-Host "1. Destroying everything..." -ForegroundColor Yellow
docker stop pgdb
docker rm pgdb
docker volume ls -q | ForEach-Object { docker volume rm $_ -f 2>$null }

Write-Host "   Waiting 10 seconds..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

# 2. Verify nothing is on port 5432
Write-Host ""
Write-Host "2. Checking port 5432..." -ForegroundColor Yellow
$portCheck = netstat -ano | Select-String ":5432"
if ($portCheck) {
    Write-Host "   WARNING: Port still in use!" -ForegroundColor Red
    Write-Host $portCheck
    Write-Host "   Waiting 10 more seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
}

# 3. Create COMPLETELY fresh database with NO PASSWORD from start
Write-Host ""
Write-Host "3. Creating fresh database (no password from the start)..." -ForegroundColor Yellow
docker run -d `
  --name pgfresh `
  -e POSTGRES_HOST_AUTH_METHOD=trust `
  -e POSTGRES_DB=mydb `
  -p 5432:5432 `
  postgres:15-alpine

Write-Host "   Waiting 25 seconds for fresh initialization..." -ForegroundColor Cyan
Start-Sleep -Seconds 25

# 4. Test inside container
Write-Host ""
Write-Host "4. Testing inside container..." -ForegroundColor Yellow
docker exec pgfresh psql -U postgres -d mydb -c "SELECT 'Inside works' as test;"

# 5. Test JDBC from host
Write-Host ""
Write-Host "5. Testing JDBC from host..." -ForegroundColor Yellow

cd C:\myNextJsProject\nextID\backend

$testJava = @"
import java.sql.*;
public class FreshTest {
    public static void main(String[] args) {
        try {
            Connection c = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/mydb?user=postgres"
            );
            System.out.println("SUCCESS - Fresh database works!");
            
            Statement s = c.createStatement();
            ResultSet rs = s.executeQuery("SELECT current_user, current_database()");
            rs.next();
            System.out.println("Connected as: " + rs.getString(1) + " to database: " + rs.getString(2));
            
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

$testJava | Out-File "FreshTest.java" -Encoding ASCII

$pgJar = Get-ChildItem "$env:USERPROFILE\.m2\repository\org\postgresql\postgresql" -Recurse -Filter "*.jar" | Where-Object { $_.Name -notlike "*-sources.jar" } | Select-Object -First 1

javac FreshTest.java
java -cp ".;$($pgJar.FullName)" FreshTest

$result = $LASTEXITCODE

if ($result -eq 0) {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "✓✓✓ FRESH DATABASE WORKS! ✓✓✓" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    
    # Update Spring Boot
    Write-Host "6. Updating Spring Boot config..." -ForegroundColor Yellow
    
    $config = @"
spring.datasource.url=jdbc:postgresql://localhost:5432/mydb?user=postgres
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
    Write-Host "7. Building..." -ForegroundColor Yellow
    mvn clean compile -DskipTests -q
    Copy-Item "src\main\resources\application.properties" "target\classes\application.properties" -Force
    
    # Start
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "STARTING SPRING BOOT" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Database: postgres @ localhost:5432/mydb (no password)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "If you see 'Started IamApplication', YOU'RE DONE!" -ForegroundColor Yellow
    Write-Host ""
    
    mvn spring-boot:run
    
} else {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "STILL FAILED!" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "At this point, the issue is likely:" -ForegroundColor Yellow
    Write-Host "  1. Windows Firewall blocking Java" -ForegroundColor White
    Write-Host "  2. Antivirus blocking JDBC connections" -ForegroundColor White
    Write-Host "  3. Docker Desktop networking is broken" -ForegroundColor White
    Write-Host ""
    Write-Host "Try running PowerShell as Administrator" -ForegroundColor Cyan
}