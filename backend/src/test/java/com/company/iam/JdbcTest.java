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
