import java.sql.*;
public class QuickTest {
    public static void main(String[] args) {
        try {
            Connection c = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/simpledb",
                "simpleuser",
                "simplepass"
            );
            System.out.println("SUCCESS");
            c.close();
            System.exit(0);
        } catch (Exception e) {
            System.out.println("FAILED: " + e.getMessage());
            System.exit(1);
        }
    }
}
