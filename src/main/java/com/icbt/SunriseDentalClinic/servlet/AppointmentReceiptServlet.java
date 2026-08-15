package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.util.AppointmentValidator;
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
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/appointmentReceipt")
public class AppointmentReceiptServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String sql = "SELECT a.id, a.appointment_date, a.appointment_time, a.reason_for_visit, a.notes, a.status, " +
                "a.consultation_fee, a.total_amount, " +
                "p.name AS patient_name, p.phone AS patient_phone, p.address AS patient_address, " +
                "d.name AS doctor_name, d.qualifications " +
                "FROM appointments a " +
                "JOIN patients p ON p.id = a.patient_id JOIN doctors d ON d.id = a.doctor_id " +
                "WHERE a.id = ?";

        DecimalFormat money = new DecimalFormat("#,##0.00");

        try (Connection conn = DBConnection.getConnection()) {

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("appointments");
                        return;
                    }
                    int appointmentId = rs.getInt("id");
                    request.setAttribute("appointmentNumber", AppointmentValidator.formatAppointmentNumber(appointmentId));
                    request.setAttribute("patientName", rs.getString("patient_name"));
                    request.setAttribute("patientPhone", rs.getString("patient_phone"));
                    request.setAttribute("patientAddress", rs.getString("patient_address"));
                    request.setAttribute("doctorName", rs.getString("doctor_name"));
                    request.setAttribute("qualifications", rs.getString("qualifications"));
                    request.setAttribute("date", new SimpleDateFormat("EEEE, MMM d, yyyy").format(rs.getDate("appointment_date")));
                    request.setAttribute("time", new SimpleDateFormat("h:mm a").format(rs.getTime("appointment_time")));
                    String reason = rs.getString("reason_for_visit");
                    request.setAttribute("reason", reason == null || reason.isEmpty() ? "General visit" : reason);
                    request.setAttribute("status", rs.getString("status"));

                    // Only a Completed appointment has been billed - consultation_fee/
                    // total_amount are NULL until ConfirmAppointmentPaymentServlet sets them.
                    BigDecimal totalAmount = rs.getBigDecimal("total_amount");
                    if (totalAmount != null) {
                        request.setAttribute("billed", true);
                        request.setAttribute("consultationFee", money.format(rs.getBigDecimal("consultation_fee")));
                        request.setAttribute("totalAmount", money.format(totalAmount));
                    }
                }
            }

            List<Map<String, String>> billedServices = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT service_name, price FROM appointment_services WHERE appointment_id = ?")) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> row = new LinkedHashMap<>();
                        row.put("name", rs.getString("service_name"));
                        row.put("price", money.format(rs.getBigDecimal("price")));
                        billedServices.add(row);
                    }
                }
            }
            request.setAttribute("billedServices", billedServices);

        } catch (SQLException e) {
            throw new ServletException("Database error while loading appointment receipt", e);
        }

        request.getRequestDispatcher("appointment-receipt.jsp").forward(request, response);
    }
}
