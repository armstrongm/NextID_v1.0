Write-Host "=====================================" -ForegroundColor Red
Write-Host "FIXING MULTIPLE POSTGRESQL INSTANCES" -ForegroundColor Red
Write-Host "=====================================" -ForegroundColor Red
Write-Host ""

# 1. Stop Docker PostgreSQL
Write-Host "1. Stopping Docker PostgreSQL..." -ForegroundColor Yellow
docker stop pgfresh pgdb 2>$null
docker rm pgfresh pgdb 2>$null

# 2. Find what's using port 5432
Write-Host ""
Write-Host "2. Finding processes on port 5432..." -ForegroundColor Yellow
$processes = netstat -ano | Select-String ":5432" | Select-String "LISTENING"
Write-Host $processes

# Get PIDs
$pids = $processes | ForEach-Object {
    $_.Line -match '\s+(\d+)\s*$' | Out-Null
    $Matches[1]
} | Sort-Object -Unique

Write-Host ""
Write-Host "Found PIDs using port 5432: $($pids -join ', ')" -ForegroundColor Yellow

# 3. Show what these processes are
Write-Host ""
Write-Host "3. Process details:" -ForegroundColor Yellow
foreach ($pid in $pids) {
    $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host "  PID $pid : $($proc.ProcessName) - $($proc.Path)" -ForegroundColor Cyan
    }
}

# 4. Ask to kill them
Write-Host ""
$response = Read-Host "Kill these processes? (y/n)"

if ($response -eq 'y') {
    foreach ($pid in $pids) {
        Write-Host "  Killing PID $pid..." -ForegroundColor Yellow
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    }
    Write-Host "  Waiting 10 seconds..." -ForegroundColor Cyan
    Start-Sleep -Seconds 10
}

# 5. Verify port is free
Write-Host ""
Write-Host "5. Checking if port 5432 is free..." -ForegroundColor Yellow
$portCheck = netstat -ano | Select-String ":5432" | Select-String "LISTENING"
if ($portCheck) {
    Write-Host "  Port still in use!" -ForegroundColor Red
    Write-Host $portCheck
    Write-Host ""
    Write-Host "  You may need to restart Windows or use a different port" -ForegroundColor Yellow
    exit
} else {
    Write-Host "  ✓ Port 5432 is now free!" -ForegroundColor Green
}

# 6. Start fresh Docker PostgreSQL
Write-Host ""
Write-Host "6. Starting Docker PostgreSQL..." -ForegroundColor Yellow
docker run -d `
  --name pgfinal `
  -e POSTGRES_HOST_AUTH_METHOD=trust `
  -e POSTGRES_DB=finaldb `
  -p 5432:5432 `
  postgres:15-alpine

Write-Host "   Waiting 25 seconds..." -ForegroundColor Cyan
Start-Sleep -Seconds 25

# 7. Verify only ONE instance is listening
Write-Host ""
Write-Host "7. Verifying only one PostgreSQL is listening..." -ForegroundColor Yellow
$listening = netstat -ano | Select-String ":5432" | Select-String "LISTENING"
$count = ($listening | Measure-Object).Count

if ($count -eq 1) {
    Write-Host "  ✓ Only ONE instance on port 5432" -ForegroundColor Green
} else {
    Write-Host "  ✗ Found $count instances!" -ForegroundColor Red
    Write-Host $listening
}

# 8. Test JDBC
Write-Host ""
Write-Host "8. Testing JDBC..." -ForegroundColor Yellow

cd C:\myNextJsProject\nextID\backend

$testJava = @"
import java.sql.*;
public class FinalTest {
    public static void main(String[] args) {
        try {
            Connection c = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/finaldb?user=postgres"
            );
            System.out.println("SUCCESS!");
            c.close();
            System.exit(0);
        } catch (Exception e) {
            System.out.println("FAILED: " + e.getMessage());
            System.exit(1);
        }
    }
}
"@

$testJava | Out-File "FinalTest.java" -Encoding ASCII

$pgJar = Get-ChildItem "$env:USERPROFILE\.m2\repository\org\postgresql\postgresql" -Recurse -Filter "*.jar" | Where-Object { $_.Name -notlike "*-sources.jar" } | Select-Object -First 1

javac FinalTest.java
java -cp ".;$($pgJar.FullName)" FinalTest

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "✓✓✓ SUCCESS! ✓✓✓" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    
    # Update Spring Boot
    $config = @"
spring.datasource.url=jdbc:postgresql://localhost:5432/finaldb?user=postgres
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.flyway.enabled=false
jwt.secret=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
jwt.expiration=86400000
server.port=8080
"@
    
    $config | Set-Content "src\main\resources\application.properties" -Encoding ASCII
    mvn clean compile -DskipTests -q
    Copy-Item "src\main\resources\application.properties" "target\classes\application.properties" -Force
    
    Write-Host "Starting Spring Boot..." -ForegroundColor Cyan
    mvn spring-boot:run
} else {
    Write-Host "JDBC still fails even with only one PostgreSQL instance!" -ForegroundColor Red
}