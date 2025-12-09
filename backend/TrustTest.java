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
