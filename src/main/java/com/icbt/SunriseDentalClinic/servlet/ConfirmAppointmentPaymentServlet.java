package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.util.AppointmentValidator;
import com.icbt.SunriseDentalClinic.util.BrevoMailer;
import com.icbt.SunriseDentalClinic.util.EmailTemplates;
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
import java.text.DecimalFormat;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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
            int patientId;
            java.sql.Date appointmentDate;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT doctor_id, patient_id, appointment_date, status FROM appointments WHERE id = ?")) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("appointments");
                        return;
                    }
                    doctorId = rs.getInt("doctor_id");
                    patientId = rs.getInt("patient_id");
                    appointmentDate = rs.getDate("appointment_date");
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
            List<Map<String, String>> billedServices = new ArrayList<>();
            DecimalFormat money = new DecimalFormat("#,##0.00");
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

                            Map<String, String> billed = new LinkedHashMap<>();
                            billed.put("name", name);
                            billed.put("price", money.format(price));
                            billedServices.add(billed);
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

            // Best-effort — the payment/completion is already saved regardless
            // of whether this email goes out (no email on file, Brevo/network
            // hiccup, etc.), so a failure here never undoes the above.
            try {
                sendBillEmail(conn, Integer.parseInt(id), patientId, doctorId, appointmentDate, money,
                        consultationFee, billedServices, total);
            } catch (Exception e) {
                log("Failed to send bill email for appointment " + id, e);
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while confirming appointment payment", e);
        }

        response.sendRedirect("appointmentReceipt?id=" + id + "&justPaid=1");
    }

    /** No-op if the patient has no email on file. */
    private void sendBillEmail(Connection conn, int appointmentId, int patientId, int doctorId,
                                java.sql.Date appointmentDate, DecimalFormat money, BigDecimal consultationFee,
                                List<Map<String, String>> billedServices, BigDecimal total)
            throws SQLException, IOException, InterruptedException {

        String patientName = null;
        String patientEmail = null;
        try (PreparedStatement ps = conn.prepareStatement("SELECT name, email FROM patients WHERE id = ?")) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    patientName = rs.getString("name");
                    patientEmail = rs.getString("email");
                }
            }
        }
        if (patientEmail == null || patientEmail.trim().isEmpty()) {
            return;
        }

        String doctorName = null;
        try (PreparedStatement ps = conn.prepareStatement("SELECT name FROM doctors WHERE id = ?")) {
            ps.setInt(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) doctorName = rs.getString("name");
            }
        }

        String formattedDate = appointmentDate.toLocalDate().format(DateTimeFormatter.ofPattern("EEEE, MMM d, yyyy"));

        String html = EmailTemplates.bill(patientName, AppointmentValidator.formatAppointmentNumber(appointmentId),
                doctorName, formattedDate, money.format(consultationFee), billedServices, money.format(total));
        BrevoMailer.sendBillEmail(patientEmail.trim(), patientName, html);
    }
}
