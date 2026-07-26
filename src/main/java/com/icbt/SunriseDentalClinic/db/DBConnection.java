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
    private static final String URL = "jdbc:mysql://localhost:3306/sunrisedentalclinic?useSSL=false&serverTimezone=UTC";
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
