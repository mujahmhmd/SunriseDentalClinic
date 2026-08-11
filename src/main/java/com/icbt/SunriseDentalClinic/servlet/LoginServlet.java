package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.util.RememberTokenUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
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

    private static final int REMEMBER_DAYS = 7;
    private static final int DEFAULT_DAYS = 1;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Raw values typed into the login form.
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        boolean rememberMe = "on".equals(request.getParameter("remember"));

        // Look up the account by username; the password is checked separately
        // below since the stored value is a bcrypt hash, not plain text.
        String sql = "SELECT id, password, name, role, status FROM users WHERE username = ?";

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

                    // A "remember me" token, unlike the session above, survives a
                    // server redeploy — the login stays valid until it expires
                    // (7 days if checked, 1 day by default), not just until the
                    // in-memory session gets wiped.
                    int validDays = rememberMe ? REMEMBER_DAYS : DEFAULT_DAYS;
                    String token = RememberTokenUtil.issue(rs.getInt("id"), validDays);
                    Cookie cookie = new Cookie(RememberTokenUtil.COOKIE_NAME, token);
                    cookie.setHttpOnly(true);
                    cookie.setPath(request.getContextPath() + "/");
                    cookie.setMaxAge(validDays * 24 * 3600);
                    response.addCookie(cookie);

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
