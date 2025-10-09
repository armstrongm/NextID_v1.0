cd C:\myNextJsProject\nextID\backend

Write-Host "=== SIMPLE JDBC TEST ===" -ForegroundColor Cyan
Write-Host ""

# Create test in src/test/java
$testDir = "src\test\java\com\company\iam"
New-Item -Path $testDir -ItemType Directory -Force | Out-Null

$testJava = @'
package com.company.iam;

import java.sql.*;

public class JdbcTest {
    public static void main(String[] args) {
        try {
            Connection conn = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/testdb",
                "testuser",
                "testpass"
            );
            
            System.out.println("SUCCESS - JDBC connection works!");
            
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT 1");
            rs.next();
            System.out.println("Query result: " + rs.getInt(1));
            
            conn.close();
            
        } catch (Exception e) {
            System.out.println("FAILED - Cannot connect!");
            e.printStackTrace();
        }
    }
}
'@

$testJava | Out-File "$testDir\JdbcTest.java" -Encoding ASCII

# Compile with Maven
Write-Host "Compiling..." -ForegroundColor Yellow
mvn test-compile -q

# Run with Maven (handles classpath automatically)
Write-Host "Running test..." -ForegroundColor Yellow
Write-Host ""
mvn exec:java -Dexec.mainClass="com.company.iam.JdbcTest" -Dexec.classpathScope=test