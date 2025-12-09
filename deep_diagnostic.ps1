Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "DEEP DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check container is actually running
Write-Host "1. Container status:" -ForegroundColor Yellow
docker ps --filter "name=pgdb"

# 2. Check what PostgreSQL thinks it's configured as
Write-Host ""
Write-Host "2. PostgreSQL configuration:" -ForegroundColor Yellow
docker exec pgdb psql -U trustuser -d trustdb -c "SHOW listen_addresses;"
docker exec pgdb psql -U trustuser -d trustdb -c "SELECT version();"

# 3. Check pg_hba.conf
Write-Host ""
Write-Host "3. pg_hba.conf file:" -ForegroundColor Yellow
docker exec pgdb cat /var/lib/postgresql/data/pg_hba.conf | Select-String -Pattern "^host|^local" | Select-String -NotMatch "^#"

# 4. Check what ports are actually listening
Write-Host ""
Write-Host "4. Listening ports on host:" -ForegroundColor Yellow
netstat -ano | Select-String ":5432"

# 5. Check if there are multiple PostgreSQL instances
Write-Host ""
Write-Host "5. All postgres processes:" -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*postgres*"} | Format-Table -AutoSize

# 6. Try connecting to 127.0.0.1 instead of localhost
Write-Host ""
Write-Host "6. Testing 127.0.0.1 vs localhost:" -ForegroundColor Yellow

cd C:\myNextJsProject\nextID\backend

$test127 = @"
import java.sql.*;
public class Test127 {
    public static void main(String[] args) {
        try {
            // Try 127.0.0.1
            Connection c = DriverManager.getConnection("jdbc:postgresql://127.0.0.1:5432/trustdb?user=trustuser");
            System.out.println("127.0.0.1 - SUCCESS");
            c.close();
        } catch (Exception e) {
            System.out.println("127.0.0.1 - FAILED: " + e.getMessage());
        }
        
        try {
            // Try localhost
            Connection c = DriverManager.getConnection("jdbc:postgresql://localhost:5432/trustdb?user=trustuser");
            System.out.println("localhost - SUCCESS");
            c.close();
        } catch (Exception e) {
            System.out.println("localhost - FAILED: " + e.getMessage());
        }
    }
}
"@

$test127 | Out-File "Test127.java" -Encoding ASCII
$pgJar = Get-ChildItem "$env:USERPROFILE\.m2\repository\org\postgresql\postgresql" -Recurse -Filter "*.jar" | Where-Object { $_.Name -notlike "*-sources.jar" } | Select-Object -First 1

javac Test127.java 2>$null
java -cp ".;$($pgJar.FullName)" Test127

# 7. Test with Docker's internal IP
Write-Host ""
Write-Host "7. Getting Docker container IP:" -ForegroundColor Yellow
$containerIP = docker inspect pgdb --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
Write-Host "   Container IP: $containerIP" -ForegroundColor White

if ($containerIP) {
    $testIP = @"
import java.sql.*;
public class TestIP {
    public static void main(String[] args) {
        try {
            Connection c = DriverManager.getConnection("jdbc:postgresql://$containerIP:5432/trustdb?user=trustuser");
            System.out.println("Direct IP - SUCCESS");
            c.close();
        } catch (Exception e) {
            System.out.println("Direct IP - FAILED: " + e.getMessage());
        }
    }
}
"@
    
    $testIP | Out-File "TestIP.java" -Encoding ASCII
    javac TestIP.java 2>$null
    java -cp ".;$($pgJar.FullName)" TestIP
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "ANALYSIS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan