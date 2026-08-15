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
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.regex.Pattern;

/** Settings page: lets the signed-in user change their own password. */
@WebServlet("/updateAccountPassword")
public class UpdateAccountPasswordServlet extends HttpServlet {

    // Same strength rule as StaffValidator's password check - kept as its
    // own copy, matching how the other validators in this app each keep
    // their own pattern copies too.
    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9]).{6,}$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String username = session != null ? (String) session.getAttribute("username") : null;
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        try (Connection conn = DBConnection.getConnection()) {

            int userId;
            String storedHash;
            try (PreparedStatement ps = conn.prepareStatement("SELECT id, password FROM users WHERE username = ?")) {
                ps.setString(1, username);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("login.jsp");
                        return;
                    }
                    userId = rs.getInt("id");
                    storedHash = rs.getString("password");
                }
            }

            // Re-checked here, not just via the page's AJAX gate - a request
            // can always bypass that and submit the form directly.
            if (currentPassword == null || currentPassword.isEmpty() || !BCrypt.checkpw(currentPassword, storedHash)) {
                forwardWithError(request, response, "Current password is incorrect.");
                return;
            }
            if (newPassword == null || newPassword.isEmpty()) {
                forwardWithError(request, response, "Enter a new password.");
                return;
            }
            if (!PASSWORD_PATTERN.matcher(newPassword).matches()) {
                forwardWithError(request, response,
                        "Password needs at least 6 characters, with an uppercase letter, a lowercase letter, a number and a special character.");
                return;
            }
            if (!newPassword.equals(confirmPassword)) {
                forwardWithError(request, response, "Passwords don't match.");
                return;
            }

            try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET password = ? WHERE id = ?")) {
                ps.setString(1, BCrypt.hashpw(newPassword, BCrypt.gensalt()));
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while updating password", e);
        }

        response.sendRedirect("settings?success=" + URLEncoder.encode("Password updated.", "UTF-8"));
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error)
            throws ServletException, IOException {
        request.setAttribute("passwordError", error);
        request.setAttribute("username", request.getSession().getAttribute("username"));
        request.getRequestDispatcher("settings.jsp").forward(request, response);
    }
}
