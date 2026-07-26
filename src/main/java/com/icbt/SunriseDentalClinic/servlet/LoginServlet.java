package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Raw values typed into the login form.
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Look up the account by username; the password is checked separately
        // below since the stored value is a bcrypt hash, not plain text.
        String sql = "SELECT password, name, role, status FROM users WHERE username = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                // rs.next() true means a matching username was found.
                // BCrypt.checkpw compares the typed password against the stored hash.
                if (rs.next() && BCrypt.checkpw(password, rs.getString("password"))) {

                    // Deactivated staff/admin accounts must not be able to log in.
                    if ("inactive".equals(rs.getString("status"))) {
                        request.setAttribute("error", "This account has been deactivated.");
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                        return;
                    }

                    // Correct credentials and active account: start the session
                    // and send the user to the dashboard.
                    HttpSession session = request.getSession();
                    session.setAttribute("username", username);
                    session.setAttribute("name", rs.getString("name"));
                    session.setAttribute("role", rs.getString("role"));
                    response.sendRedirect("dashboard.jsp");
                    return;
                }
            }
        } catch (SQLException e) {
            // Wrap DB failures so the container reports a clear error instead
            // of a raw SQLException.
            throw new ServletException("Database error during login", e);
        }

        // Reached only when the username wasn't found or the password didn't match.
        request.setAttribute("error", "Invalid username or password.");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}
