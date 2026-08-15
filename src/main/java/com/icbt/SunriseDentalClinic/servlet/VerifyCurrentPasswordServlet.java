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

/**
 * AJAX check backing the Change Password form on the Settings page
 * (assets/js/settings-validation.js): the new-password fields only unlock
 * once the typed current password is confirmed correct, without a full page
 * round trip. UpdateAccountPasswordServlet re-checks this independently
 * server-side when the form is actually submitted — this endpoint is UX
 * only, never the real gate, since a request can always bypass it.
 */
@WebServlet("/verifyCurrentPassword")
public class VerifyCurrentPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String username = session != null ? (String) session.getAttribute("username") : null;
        response.setContentType("application/json;charset=UTF-8");

        if (username == null) {
            response.getWriter().write("{\"valid\":false}");
            return;
        }

        String currentPassword = request.getParameter("currentPassword");
        boolean valid = false;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT password FROM users WHERE username = ?")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && currentPassword != null && !currentPassword.isEmpty()) {
                    valid = BCrypt.checkpw(currentPassword, rs.getString("password"));
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Database error while verifying current password", e);
        }

        response.getWriter().write("{\"valid\":" + valid + "}");
    }
}
