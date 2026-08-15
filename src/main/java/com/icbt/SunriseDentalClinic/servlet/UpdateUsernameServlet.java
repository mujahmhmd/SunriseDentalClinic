package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.regex.Pattern;

/** Settings page: lets the signed-in user change their own username. */
@WebServlet("/updateUsername")
public class UpdateUsernameServlet extends HttpServlet {

    // Same shape as StaffValidator's username rule - kept as its own copy,
    // matching how the other validators in this app each keep their own
    // pattern copies too.
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-z0-9][a-z0-9._-]{1,14}[a-z0-9]$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String currentUsername = session != null ? (String) session.getAttribute("username") : null;
        if (currentUsername == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String newUsername = request.getParameter("username");

        if (newUsername == null || !USERNAME_PATTERN.matcher(newUsername.trim()).matches()) {
            forwardWithError(request, response, newUsername,
                    "Username must be 3-16 characters: lowercase letters, numbers, dots, underscores or hyphens only (e.g. mujahith.mohamed).");
            return;
        }
        newUsername = newUsername.trim();

        try (Connection conn = DBConnection.getConnection()) {

            int userId;
            try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM users WHERE username = ?")) {
                ps.setString(1, currentUsername);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("login.jsp");
                        return;
                    }
                    userId = rs.getInt("id");
                }
            }

            if (!newUsername.equals(currentUsername)) {
                try (PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM users WHERE username = ? AND id <> ?")) {
                    ps.setString(1, newUsername);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            forwardWithError(request, response, newUsername, "That username is already taken.");
                            return;
                        }
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET username = ? WHERE id = ?")) {
                    ps.setString(1, newUsername);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                }

                // Everything downstream (RememberMeFilter's admin-only check, the
                // header's greeting, etc.) reads the username back out of the
                // session, so it has to be updated here too, not just in the DB.
                session.setAttribute("username", newUsername);
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while updating username", e);
        }

        response.sendRedirect("settings?success=" + URLEncoder.encode("Username updated.", "UTF-8"));
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response,
                                   String attemptedUsername, String error)
            throws ServletException, IOException {
        request.setAttribute("usernameError", error);
        request.setAttribute("username", attemptedUsername);
        request.getRequestDispatcher("settings.jsp").forward(request, response);
    }
}
