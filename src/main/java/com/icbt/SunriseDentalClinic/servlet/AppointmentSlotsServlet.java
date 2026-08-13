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
import java.util.ArrayList;
import java.util.List;

/**
 * Backs the time-tag picker on the appointment form (assets/js/appointment-slots.js).
 * Given a doctor + date (and optionally the patient already picked), reports
 * which of the standard time slots are already unavailable so the form can
 * grey them out instead of letting a clash be discovered only at submit:
 *   - "booked": this doctor already has an appointment at that time
 *   - "patientConflict": this patient already has an appointment (with any
 *     doctor) at that time — the same person can't be in two places at once
 */
@WebServlet("/appointmentSlots")
public class AppointmentSlotsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String doctorId = request.getParameter("doctorId");
        String date = request.getParameter("date");
        String patientId = request.getParameter("patientId");
        String excludeId = request.getParameter("excludeId"); // this appointment's own id, when editing

        List<String> booked = new ArrayList<>();
        List<String> patientConflict = new ArrayList<>();

        if (doctorId != null && !doctorId.trim().isEmpty() && date != null && !date.trim().isEmpty()) {
            try (Connection conn = DBConnection.getConnection()) {

                String bookedSql = "SELECT appointment_time FROM appointments " +
                        "WHERE doctor_id = ? AND appointment_date = ? AND status <> 'Cancelled'" +
                        (hasValue(excludeId) ? " AND id <> ?" : "");
                try (PreparedStatement ps = conn.prepareStatement(bookedSql)) {
                    ps.setInt(1, Integer.parseInt(doctorId.trim()));
                    ps.setDate(2, java.sql.Date.valueOf(date.trim()));
                    if (hasValue(excludeId)) ps.setInt(3, Integer.parseInt(excludeId.trim()));
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            booked.add(rs.getTime("appointment_time").toString().substring(0, 5));
                        }
                    }
                }

                if (hasValue(patientId)) {
                    String conflictSql = "SELECT appointment_time FROM appointments " +
                            "WHERE patient_id = ? AND appointment_date = ? AND status <> 'Cancelled'" +
                            (hasValue(excludeId) ? " AND id <> ?" : "");
                    try (PreparedStatement ps = conn.prepareStatement(conflictSql)) {
                        ps.setInt(1, Integer.parseInt(patientId.trim()));
                        ps.setDate(2, java.sql.Date.valueOf(date.trim()));
                        if (hasValue(excludeId)) ps.setInt(3, Integer.parseInt(excludeId.trim()));
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                patientConflict.add(rs.getTime("appointment_time").toString().substring(0, 5));
                            }
                        }
                    }
                }

            } catch (SQLException | IllegalArgumentException e) {
                throw new ServletException("Database error while loading appointment slots", e);
            }
        }

        StringBuilder json = new StringBuilder("{\"booked\":");
        appendArray(json, booked);
        json.append(",\"patientConflict\":");
        appendArray(json, patientConflict);
        json.append('}');

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(json.toString());
    }

    private static boolean hasValue(String s) {
        return s != null && !s.trim().isEmpty();
    }

    private static void appendArray(StringBuilder json, List<String> values) {
        json.append('[');
        for (int i = 0; i < values.size(); i++) {
            if (i > 0) json.append(',');
            json.append('"').append(values.get(i)).append('"');
        }
        json.append(']');
    }
}
