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
