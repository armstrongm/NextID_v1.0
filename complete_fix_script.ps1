cd C:\myNextJsProject\nextID\backend

Write-Host "=== TESTING JDBC CONNECTION ===" -ForegroundColor Cyan
Write-Host ""

# Simple test without special characters
$testJava = @"
import java.sql.*;

public class TestDB {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/testdb";
        String user = "testuser";
        String pass = "testpass";
        
        try {
            Class.forName("org.postgresql.Driver");
            System.out.println("Connecting to: " + url);
            System.out.println("User: " + user);
            
            Connection conn = DriverManager.getConnection(url, user, pass);
            
            System.out.println("========================================");
            System.out.println("SUCCESS: JDBC CONNECTION WORKS!");
            System.out.println("========================================");
            
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT version()");
            if (rs.next()) {
                System.out.println("PostgreSQL: " + rs.getString(1).substring(0, 50));
            }
            
            conn.close();
            System.exit(0);
            
        } catch (Exception e) {
            System.out.println("========================================");
            System.out.println("FAILED: JDBC CONNECTION ERROR!");
            System.out.println("========================================");
            System.out.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
"@

$testJava | Out-File "TestDB.java" -Encoding ASCII

# Find PostgreSQL JAR
Write-Host "Finding PostgreSQL JDBC driver..." -ForegroundColor Yellow
$pgJar = Get-ChildItem "$env:USERPROFILE\.m2\repository\org\postgresql\postgresql" -Recurse -Filter "*.jar" | Where-Object { $_.Name -notlike "*-sources.jar" } | Select-Object -First 1

if ($pgJar) {
    Write-Host "Found: $($pgJar.FullName)" -ForegroundColor Green
    Write-Host ""
    
    # Compile
    Write-Host "Compiling test..." -ForegroundColor Yellow
    javac TestDB.java
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Compiled successfully" -ForegroundColor Green
        Write-Host ""
        
        # Run
        Write-Host "Running JDBC test..." -ForegroundColor Yellow
        Write-Host ""
        java -cp ".;$($pgJar.FullName)" TestDB
        
        $result = $LASTEXITCODE
        
        Write-Host ""
        if ($result -eq 0) {
            Write-Host "=====================================" -ForegroundColor Green
            Write-Host "JDBC TEST PASSED!" -ForegroundColor Green
            Write-Host "=====================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "This means:" -ForegroundColor Cyan
            Write-Host "  - Database is accessible from host" -ForegroundColor White
            Write-Host "  - Credentials are correct" -ForegroundColor White
            Write-Host "  - Spring Boot SHOULD work!" -ForegroundColor White
            Write-Host ""
        } else {
            Write-Host "=====================================" -ForegroundColor Red
            Write-Host "JDBC TEST FAILED!" -ForegroundColor Red
            Write-Host "=====================================" -ForegroundColor Red
            Write-Host ""
            Write-Host "This is the root cause!" -ForegroundColor Yellow
            Write-Host "The database is NOT accessible from the host machine." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Possible issues:" -ForegroundColor Cyan
            Write-Host "  1. PostgreSQL not listening on 0.0.0.0" -ForegroundColor White
            Write-Host "  2. pg_hba.conf blocking connections" -ForegroundColor White
            Write-Host "  3. Firewall blocking port 5432" -ForegroundColor White
            Write-Host ""
            exit
        }
    } else {
        Write-Host "Compilation failed!" -ForegroundColor Red
        exit
    }
} else {
    Write-Host "PostgreSQL JDBC driver not found!" -ForegroundColor Red
    Write-Host "Run: mvn dependency:resolve" -ForegroundColor Yellow
    exit
}

# Now try Spring Boot
Write-Host "Press Enter to start Spring Boot..."
Read-Host

Write-Host ""
Write-Host "Starting Spring Boot..." -ForegroundColor Cyan
mvn spring-boot:run