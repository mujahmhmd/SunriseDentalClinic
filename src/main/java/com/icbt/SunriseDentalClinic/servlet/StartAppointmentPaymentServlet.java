package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Opens the payment popup on the appointments page: flips the appointment to
 * 'Processing Payment' (also works to *reopen* the popup on an appointment
 * already in that state, e.g. after a browser refresh) and reports the
 * doctor's consultation fee plus the active Services catalog so the popup
 * has everything it needs to render without a second request.
 */
@WebServlet("/startAppointmentPayment")
public class StartAppointmentPaymentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");

        try (Connection conn = DBConnection.getConnection()) {

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE appointments SET status = 'Processing Payment' " +
                            "WHERE id = ? AND status IN ('Scheduled', 'Processing Payment')")) {
                ps.setString(1, id);
                ps.executeUpdate();
            }

            BigDecimal consultationFee = BigDecimal.ZERO;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT d.consultation_fee FROM appointments a " +
                            "JOIN doctors d ON d.id = a.doctor_id WHERE a.id = ?")) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        BigDecimal fee = rs.getBigDecimal("consultation_fee");
                        if (fee != null) consultationFee = fee;
                    }
                }
            }

            StringBuilder json = new StringBuilder("{\"consultationFee\":")
                    .append(consultationFee.toPlainString())
                    .append(",\"services\":[");
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id, name, price FROM services WHERE status = 'active' ORDER BY name");
                 ResultSet rs = ps.executeQuery()) {
                boolean first = true;
                while (rs.next()) {
                    if (!first) json.append(',');
                    first = false;
                    json.append('{')
                            .append("\"id\":").append(rs.getInt("id")).append(',')
                            .append("\"name\":\"").append(escape(rs.getString("name"))).append("\",")
                            .append("\"price\":").append(rs.getBigDecimal("price").toPlainString())
                            .append('}');
                }
            }
            json.append("]}");

            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write(json.toString());

        } catch (SQLException e) {
            throw new ServletException("Database error while starting appointment payment", e);
        }
    }

    private static String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
