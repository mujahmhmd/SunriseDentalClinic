package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.util.StaffValidator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/editStaff")
public class EditStaffServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String sql = "SELECT id, name, nic, address, phone, email, username FROM users WHERE id = ? AND role = 'staff'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    response.sendRedirect("staffs");
                    return;
                }
                request.setAttribute("id", rs.getString("id"));
                request.setAttribute("name", rs.getString("name"));
                request.setAttribute("nic", rs.getString("nic"));
                request.setAttribute("address", rs.getString("address"));
                request.setAttribute("phone", rs.getString("phone"));
                request.setAttribute("email", rs.getString("email"));
                request.setAttribute("username", rs.getString("username"));
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while loading staff", e);
        }

        request.getRequestDispatcher("edit-staff.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String nic = request.getParameter("nic");
        String address = request.getParameter("address");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String username = request.getParameter("username");
        String password = request.getParameter("password"); // optional: blank keeps the current password

        String validationError = StaffValidator.validate(name, nic, phone, email, username, password, false);
        if (validationError != null) {
            forwardWithError(request, response, validationError, id, name, nic, address, phone, email, username);
            return;
        }

        String checkUsernameSql = "SELECT 1 FROM users WHERE username = ? AND id <> ?";
        String checkEmailSql = "SELECT 1 FROM users WHERE email = ? AND id <> ?";
        String checkNicSql = "SELECT 1 FROM users WHERE nic = ? AND id <> ?";
        String updateSqlBase = "UPDATE users SET name = ?, nic = ?, address = ?, phone = ?, email = ?, username = ?";

        try (Connection conn = DBConnection.getConnection()) {

            // Excludes this staff member's own id so re-saving their unchanged
            // username/email/NIC isn't mistaken for a clash.
            try (PreparedStatement ps = conn.prepareStatement(checkUsernameSql)) {
                ps.setString(1, username.trim());
                ps.setString(2, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        forwardWithError(request, response, "That username is already taken.", id, name, nic, address, phone, email, username);
                        return;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(checkEmailSql)) {
                ps.setString(1, email.trim());
                ps.setString(2, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        forwardWithError(request, response, "That email is already in use.", id, name, nic, address, phone, email, username);
                        return;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(checkNicSql)) {
                ps.setString(1, nic.trim());
                ps.setString(2, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        forwardWithError(request, response, "A staff account already exists with this NIC.", id, name, nic, address, phone, email, username);
                        return;
                    }
                }
            }

            boolean changePassword = !isBlank(password);
            String updateSql = updateSqlBase + (changePassword ? ", password = ? WHERE id = ?" : " WHERE id = ?");

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, name.trim());
                ps.setString(2, nic.trim());
                ps.setString(3, address == null ? null : address.trim());
                ps.setString(4, StaffValidator.normalizePhone(phone));
                ps.setString(5, email.trim());
                ps.setString(6, username.trim());
                if (changePassword) {
                    ps.setString(7, BCrypt.hashpw(password, BCrypt.gensalt()));
                    ps.setString(8, id);
                } else {
                    ps.setString(7, id);
                }
                ps.executeUpdate();
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while updating staff", e);
        }

        response.sendRedirect("staffs?success=" + URLEncoder.encode("Staff details updated", "UTF-8"));
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error,
                                   String id, String name, String nic, String address, String phone, String email, String username)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("id", id);
        request.setAttribute("name", name);
        request.setAttribute("nic", nic);
        request.setAttribute("address", address);
        request.setAttribute("phone", phone);
        request.setAttribute("email", email);
        request.setAttribute("username", username);
        request.getRequestDispatcher("edit-staff.jsp").forward(request, response);
    }
}
