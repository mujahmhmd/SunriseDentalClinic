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
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Landing page after login — a handful of at-a-glance stats plus today's
 * appointment schedule, each pulled from data the rest of the app already
 * maintains (nothing new is tracked just for this page).
 */
@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LocalDate today = LocalDate.now();
        Date sqlToday = Date.valueOf(today);
        Date monthStart = Date.valueOf(today.withDayOfMonth(1));
        Date monthEnd = Date.valueOf(today.withDayOfMonth(today.lengthOfMonth()));

        try (Connection conn = DBConnection.getConnection()) {

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM appointments WHERE appointment_date = ? AND status <> 'Cancelled'")) {
                ps.setDate(1, sqlToday);
                try (ResultSet rs = ps.executeQuery()) {
                    request.setAttribute("todaysAppointmentCount", rs.next() ? rs.getInt(1) : 0);
                }
            }

            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM patients");
                 ResultSet rs = ps.executeQuery()) {
                request.setAttribute("totalPatients", rs.next() ? rs.getInt(1) : 0);
            }

            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM doctors WHERE status = 'active'");
                 ResultSet rs = ps.executeQuery()) {
                request.setAttribute("activeDoctors", rs.next() ? rs.getInt(1) : 0);
            }

            DecimalFormat money = new DecimalFormat("#,##0.00");
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COALESCE(SUM(total_amount), 0) FROM appointments " +
                            "WHERE total_amount IS NOT NULL AND appointment_date BETWEEN ? AND ?")) {
                ps.setDate(1, monthStart);
                ps.setDate(2, monthEnd);
                try (ResultSet rs = ps.executeQuery()) {
                    BigDecimal revenue = rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
                    request.setAttribute("revenueThisMonth", money.format(revenue));
                }
            }

            List<Map<String, String>> todaysSchedule = new ArrayList<>();
            String scheduleSql = "SELECT a.id, a.appointment_time, a.status, " +
                    "p.name AS patient_name, d.name AS doctor_name " +
                    "FROM appointments a " +
                    "JOIN patients p ON p.id = a.patient_id JOIN doctors d ON d.id = a.doctor_id " +
                    "WHERE a.appointment_date = ? AND a.status <> 'Cancelled' " +
                    "ORDER BY a.appointment_time";
            try (PreparedStatement ps = conn.prepareStatement(scheduleSql)) {
                ps.setDate(1, sqlToday);
                SimpleDateFormat timeFormat = new SimpleDateFormat("h:mm a");
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> row = new LinkedHashMap<>();
                        int id = rs.getInt("id");
                        row.put("id", String.valueOf(id));
                        row.put("appointmentNumber", AppointmentValidator.formatAppointmentNumber(id));
                        row.put("time", timeFormat.format(rs.getTime("appointment_time")));
                        row.put("patientName", rs.getString("patient_name"));
                        row.put("doctorName", rs.getString("doctor_name"));
                        row.put("status", rs.getString("status"));
                        todaysSchedule.add(row);
                    }
                }
            }
            request.setAttribute("todaysSchedule", todaysSchedule);

        } catch (SQLException e) {
            throw new ServletException("Database error while loading dashboard", e);
        }

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}
