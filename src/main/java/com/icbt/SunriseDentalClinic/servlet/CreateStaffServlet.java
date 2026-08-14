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

@WebServlet("/createStaff")
public class CreateStaffServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String nic = request.getParameter("nic");
        String address = request.getParameter("address");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        String validationError = StaffValidator.validate(name, nic, phone, email, username, password, true);
        if (validationError != null) {
            forwardWithError(request, response, validationError, name, nic, address, phone, email, username);
            return;
        }

        String checkUsernameSql = "SELECT 1 FROM users WHERE username = ?";
        String checkEmailSql = "SELECT 1 FROM users WHERE email = ?";
        String insertSql = "INSERT INTO users (username, password, name, nic, address, phone, email, role, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, 'staff', 'active')";

        try (Connection conn = DBConnection.getConnection()) {

            // Checked explicitly (rather than relying on the UNIQUE constraint
            // failing) so we can show a friendly message instead of a raw SQL error.
            try (PreparedStatement ps = conn.prepareStatement(checkUsernameSql)) {
                ps.setString(1, username.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        forwardWithError(request, response, "That username is already taken.", name, nic, address, phone, email, username);
                        return;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(checkEmailSql)) {
                ps.setString(1, email.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        forwardWithError(request, response, "That email is already in use.", name, nic, address, phone, email, username);
                        return;
                    }
                }
            }

            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, username.trim());
                ps.setString(2, hashedPassword);
                ps.setString(3, name.trim());
                ps.setString(4, nic.trim());
                ps.setString(5, address == null ? null : address.trim());
                ps.setString(6, StaffValidator.normalizePhone(phone));
                ps.setString(7, email.trim());
                ps.executeUpdate();
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while creating staff", e);
        }

        response.sendRedirect("staffs?success=" + URLEncoder.encode("Staff account created", "UTF-8"));
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error,
                                   String name, String nic, String address, String phone, String email, String username)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("name", name);
        request.setAttribute("nic", nic);
        request.setAttribute("address", address);
        request.setAttribute("phone", phone);
        request.setAttribute("email", email);
        request.setAttribute("username", username);
        request.getRequestDispatcher("create-staff.jsp").forward(request, response);
    }
}
