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
