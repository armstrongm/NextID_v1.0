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
