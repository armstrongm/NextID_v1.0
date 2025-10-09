import java.sql.*;
public class Test {
    public static void main(String[] args) {
        try {
            Connection c = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/appdb",
                "appuser",
                "apppass123"
            );
            System.out.println("SUCCESS");
            c.close();
        } catch (Exception e) {
            System.out.println("FAILED: " + e.getMessage());
        }
    }
}
