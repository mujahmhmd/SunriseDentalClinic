package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * AJAX check backing the live NIC/Email availability check on the
 * Create/Edit Staff forms (assets/js/staff-form-validation.js) - same idea
 * as CheckDoctorFieldServlet, just against the users table. UX only, never
 * the real gate; CreateStaffServlet/EditStaffServlet re-check the same
 * thing themselves when the form is actually submitted.
 *
 * Checked across all users (not just role='staff'), matching how the
 * existing username/email uniqueness checks in those servlets already
 * don't filter by role either - one NIC or email shouldn't belong to both
 * a staff account and the admin account.
 *
 * "field" is looked up against a fixed whitelist (never interpolated
 * straight into SQL) so it can't be used to probe arbitrary columns.
 */
@WebServlet("/checkStaffField")
public class CheckStaffFieldServlet extends HttpServlet {

    private static final Map<String, String> FIELD_TO_COLUMN = new HashMap<>();
    static {
        FIELD_TO_COLUMN.put("nic", "nic");
        FIELD_TO_COLUMN.put("email", "email");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String field = request.getParameter("field");
        String value = request.getParameter("value");
        String excludeId = request.getParameter("excludeId");
        response.setContentType("application/json;charset=UTF-8");

        String column = FIELD_TO_COLUMN.get(field);
        if (column == null || value == null || value.trim().isEmpty()) {
            response.getWriter().write("{\"available\":true}");
            return;
        }

        boolean excludeSelf = excludeId != null && !excludeId.trim().isEmpty();
        String sql = "SELECT 1 FROM users WHERE " + column + " = ?" + (excludeSelf ? " AND id <> ?" : "");

        boolean available;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, value.trim());
            if (excludeSelf) {
                ps.setString(2, excludeId.trim());
            }
            try (ResultSet rs = ps.executeQuery()) {
                available = !rs.next();
            }
        } catch (SQLException e) {
            throw new ServletException("Database error while checking staff field availability", e);
        }

        response.getWriter().write("{\"available\":" + available + "}");
    }
}
