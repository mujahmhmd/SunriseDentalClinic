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
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/appointments")
public class AppointmentServlet extends HttpServlet {

    private static final int PAGE_SIZE = 8;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("q");
        if (search == null) search = "";

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException ignored) {
            // Missing or invalid page param just falls back to page 1.
        }
        if (page < 1) page = 1;

        String likeTerm = "%" + search + "%";

        String countSql = "SELECT COUNT(*) FROM appointments a " +
                "JOIN patients p ON p.id = a.patient_id JOIN doctors d ON d.id = a.doctor_id " +
                "WHERE p.name LIKE ? OR d.name LIKE ?";
        String listSql = "SELECT a.id, p.name AS patient_name, p.phone AS patient_phone, " +
                "d.name AS doctor_name, a.appointment_date, a.appointment_time, a.reason_for_visit, a.status, " +
                "a.reopened_by, a.reopened_at, a.reopen_reason, a.reopen_previous_total " +
                "FROM appointments a " +
                "JOIN patients p ON p.id = a.patient_id JOIN doctors d ON d.id = a.doctor_id " +
                "WHERE p.name LIKE ? OR d.name LIKE ? " +
                "ORDER BY a.appointment_date DESC, a.appointment_time DESC LIMIT ? OFFSET ?";

        List<Map<String, String>> appointmentList = new ArrayList<>();
        int totalCount = 0;

        try (Connection conn = DBConnection.getConnection()) {

            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setString(1, likeTerm);
                ps.setString(2, likeTerm);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalCount = rs.getInt(1);
                }
            }

            int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) PAGE_SIZE));
            if (page > totalPages) page = totalPages;
            int offset = (page - 1) * PAGE_SIZE;

            SimpleDateFormat dateFormat = new SimpleDateFormat("MMM d, yyyy");
            SimpleDateFormat timeFormat = new SimpleDateFormat("h:mm a");
            SimpleDateFormat reopenedAtFormat = new SimpleDateFormat("MMM d, h:mm a");
            DecimalFormat money = new DecimalFormat("#,##0.00");

            try (PreparedStatement ps = conn.prepareStatement(listSql)) {
                ps.setString(1, likeTerm);
                ps.setString(2, likeTerm);
                ps.setInt(3, PAGE_SIZE);
                ps.setInt(4, offset);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> row = new LinkedHashMap<>();
                        int id = rs.getInt("id");
                        row.put("id", String.valueOf(id));
                        row.put("appointmentNumber", com.icbt.SunriseDentalClinic.util.AppointmentValidator.formatAppointmentNumber(id));
                        row.put("patientName", rs.getString("patient_name"));
                        row.put("patientPhone", rs.getString("patient_phone"));
                        row.put("doctorName", rs.getString("doctor_name"));
                        java.sql.Date apptDate = rs.getDate("appointment_date");
                        java.sql.Time apptTime = rs.getTime("appointment_time");
                        row.put("date", dateFormat.format(apptDate));
                        row.put("time", timeFormat.format(apptTime));

                        // Complete & Bill only makes sense once the appointment's day has
                        // arrived - staff shouldn't be able to bill an appointment that's
                        // still on a future date. Date-only on purpose (not date+time): a
                        // 4pm appointment can still be completed earlier that same day,
                        // e.g. if the patient came in ahead of schedule. Compared as a
                        // plain local date, same as how appointment_date was written in
                        // the first place (Date.valueOf, no timezone math) -
                        // StartAppointmentPaymentServlet re-checks this for real, this
                        // flag only controls whether the button even renders enabled.
                        boolean canComplete = !apptDate.toLocalDate().isAfter(java.time.LocalDate.now());
                        row.put("canComplete", String.valueOf(canComplete));
                        String reason = rs.getString("reason_for_visit");
                        row.put("reason", reason == null ? "" : reason);
                        row.put("status", rs.getString("status"));

                        String reopenedBy = rs.getString("reopened_by");
                        if (reopenedBy != null) {
                            row.put("reopenedBy", reopenedBy);
                            row.put("reopenedAt", reopenedAtFormat.format(rs.getTimestamp("reopened_at")));
                            String reopenReason = rs.getString("reopen_reason");
                            row.put("reopenReason", reopenReason == null ? "" : reopenReason);
                            BigDecimal previousTotal = rs.getBigDecimal("reopen_previous_total");
                            row.put("reopenPreviousTotal", previousTotal == null ? "" : money.format(previousTotal));
                        }

                        appointmentList.add(row);
                    }
                }
            }

            request.setAttribute("appointmentList", appointmentList);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", PAGE_SIZE);
            request.setAttribute("searchQuery", search);

        } catch (SQLException e) {
            throw new ServletException("Database error while loading appointment list", e);
        }

        // Live search/pagination requests only need the table fragment re-rendered,
        // not the full page (sidebar, header, etc.) again.
        boolean isAjax = "1".equals(request.getParameter("ajax"));
        String target = isAjax ? "components/appointment-table.jsp" : "appointments.jsp";
        request.getRequestDispatcher(target).forward(request, response);
    }
}
