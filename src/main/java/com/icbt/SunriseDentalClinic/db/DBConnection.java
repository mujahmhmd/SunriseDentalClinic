package com.icbt.SunriseDentalClinic.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Opens JDBC connections to the local XAMPP MySQL instance.
 * Update USER/PASSWORD here if your XAMPP MySQL root account is not the default.
 */
public class DBConnection {

    // JDBC URL for the local XAMPP MySQL instance and the "sunrisedentalclinic" database.
    // serverTimezone must match the MySQL server's actual clock (its time_zone
    // system variable is SYSTEM, which resolves to Asia/Colombo on this host) -
    // not the timezone we'd *like* it to be. A mismatch here doesn't error, it
    // just silently shifts every TIMESTAMP round-tripped through JDBC by the
    // difference (discovered via forgot-password OTPs expiring the instant
    // they were issued, since expires_at was landing ~5.5h in the past).
    private static final String URL = "jdbc:mysql://localhost:3306/sunrisedentalclinic?useSSL=false&serverTimezone=Asia/Colombo";
    private static final String USER = "root";
    private static final String PASSWORD = ""; // default XAMPP root password is empty

    // Runs once when this class is first used. Registers the MySQL driver so
    // DriverManager can find it even if the container's classloader doesn't
    // auto-detect it on its own.
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC driver not found on classpath", e);
        }
    }

    // Opens a fresh connection; callers are responsible for closing it
    // (use try-with-resources, as LoginServlet does).
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
