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
 * Confirms the payment popup on an appointment: snapshots the doctor's
 * consultation fee and the price/name of every ticked service (so a later
 * edit to either doesn't rewrite an already-charged bill), sums the total,
 * and marks the appointment Completed.
 */
@WebServlet("/confirmAppointmentPayment")
public class ConfirmAppointmentPaymentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String[] serviceIds = request.getParameterValues("serviceIds");

        try (Connection conn = DBConnection.getConnection()) {

            boolean processingPayment;
            int doctorId;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT doctor_id, status FROM appointments WHERE id = ?")) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("appointments");
                        return;
                    }
                    doctorId = rs.getInt("doctor_id");
                    processingPayment = "Processing Payment".equals(rs.getString("status"));
                }
            }
            if (!processingPayment) {
                // Stale/duplicate submit (e.g. double-click, or the popup was
                // cancelled in another tab) — nothing to charge.
                response.sendRedirect("appointments");
                return;
            }

            BigDecimal consultationFee = BigDecimal.ZERO;
            try (PreparedStatement ps = conn.prepareStatement("SELECT consultation_fee FROM doctors WHERE id = ?")) {
                ps.setInt(1, doctorId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        BigDecimal fee = rs.getBigDecimal("consultation_fee");
                        if (fee != null) consultationFee = fee;
                    }
                }
            }

            BigDecimal total = consultationFee;
            if (serviceIds != null && serviceIds.length > 0) {
                try (PreparedStatement lookup = conn.prepareStatement("SELECT name, price FROM services WHERE id = ?");
                     PreparedStatement insert = conn.prepareStatement(
                             "INSERT INTO appointment_services (appointment_id, service_id, service_name, price) VALUES (?, ?, ?, ?)")) {
                    for (String serviceId : serviceIds) {
                        int sid;
                        try {
                            sid = Integer.parseInt(serviceId.trim());
                        } catch (NumberFormatException e) {
                            continue;
                        }
                        // Re-read fresh from the DB rather than trusting anything
                        // the client sent, so a tampered price can't be submitted.
                        lookup.setInt(1, sid);
                        try (ResultSet rs = lookup.executeQuery()) {
                            if (!rs.next()) continue;
                            String name = rs.getString("name");
                            BigDecimal price = rs.getBigDecimal("price");
                            insert.setString(1, id);
                            insert.setInt(2, sid);
                            insert.setString(3, name);
                            insert.setBigDecimal(4, price);
                            insert.executeUpdate();
                            total = total.add(price);
                        }
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE appointments SET status = 'Completed', consultation_fee = ?, total_amount = ? " +
                            "WHERE id = ? AND status = 'Processing Payment'")) {
                ps.setBigDecimal(1, consultationFee);
                ps.setBigDecimal(2, total);
                ps.setString(3, id);
                ps.executeUpdate();
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while confirming appointment payment", e);
        }

        response.sendRedirect("appointmentReceipt?id=" + id + "&justPaid=1");
    }
}
