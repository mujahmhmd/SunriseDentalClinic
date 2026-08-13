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

/**
 * Backs the patient search/autofill combobox on the appointment form
 * (assets/js/patient-search.js). Returns a small hand-built JSON array
 * rather than pulling in a JSON library, since this is the only place in
 * the app that needs one and the shape is a flat, fixed field list.
 */
@WebServlet("/searchPatients")
public class PatientSearchServlet extends HttpServlet {

    private static final int MAX_RESULTS = 8;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String q = request.getParameter("q");
        if (q == null) q = "";
        String likeTerm = "%" + q.trim() + "%";

        String sql = "SELECT id, name, phone, nic FROM patients " +
                "WHERE name LIKE ? OR phone LIKE ? OR nic LIKE ? ORDER BY name LIMIT ?";

        StringBuilder json = new StringBuilder("[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, likeTerm);
            ps.setString(2, likeTerm);
            ps.setString(3, likeTerm);
            ps.setInt(4, MAX_RESULTS);

            try (ResultSet rs = ps.executeQuery()) {
                boolean first = true;
                while (rs.next()) {
                    if (!first) json.append(',');
                    first = false;
                    json.append('{')
                            .append("\"id\":").append(rs.getInt("id")).append(',')
                            .append("\"name\":\"").append(escape(rs.getString("name"))).append("\",")
                            .append("\"phone\":\"").append(escape(rs.getString("phone"))).append("\",")
                            .append("\"nic\":\"").append(escape(rs.getString("nic"))).append("\"")
                            .append('}');
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Database error while searching patients", e);
        }
        json.append(']');

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(json.toString());
    }

    private static String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
