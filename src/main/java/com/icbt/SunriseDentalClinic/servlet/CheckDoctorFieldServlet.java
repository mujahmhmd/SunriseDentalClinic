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
 * AJAX check backing the live NIC/SLMC Reg No availability check on the
 * Create/Edit Doctor forms (assets/js/doctor-form-validation.js): as the
 * admin types, this reports whether the value already belongs to another
 * doctor, so the error shows right under the field instead of only after
 * submitting the whole form. UX only, never the real gate — a request can
 * always bypass it, so CreateDoctorServlet/EditDoctorServlet re-check the
 * same thing themselves when the form is actually submitted.
 *
 * "field" is looked up against a fixed whitelist (never interpolated
 * straight into SQL) so it can't be used to probe arbitrary columns.
 */
@WebServlet("/checkDoctorField")
public class CheckDoctorFieldServlet extends HttpServlet {

    private static final Map<String, String> FIELD_TO_COLUMN = new HashMap<>();
    static {
        FIELD_TO_COLUMN.put("nic", "nic");
        FIELD_TO_COLUMN.put("slmcRegNo", "slmc_reg_no");
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
        String sql = "SELECT 1 FROM doctors WHERE " + column + " = ?" + (excludeSelf ? " AND id <> ?" : "");

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
            throw new ServletException("Database error while checking doctor field availability", e);
        }

        response.getWriter().write("{\"available\":" + available + "}");
    }
}
