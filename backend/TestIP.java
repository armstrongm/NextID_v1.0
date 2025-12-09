import java.sql.*;
public class TestIP {
    public static void main(String[] args) {
        try {
            Connection c = DriverManager.getConnection("jdbc:postgresql:///trustdb?user=trustuser");
            System.out.println("Direct IP - SUCCESS");
            c.close();
        } catch (Exception e) {
            System.out.println("Direct IP - FAILED: " + e.getMessage());
        }
    }
}
