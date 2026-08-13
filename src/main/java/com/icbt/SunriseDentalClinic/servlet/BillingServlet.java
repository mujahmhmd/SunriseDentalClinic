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
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Read-only ledger of every billed (Completed) appointment — a different
 * view over the same appointments/appointment_services data the receipt
 * pulls from, filtered to only rows that actually have a total_amount, with
 * search and an optional date range plus a revenue total for whatever's
 * currently filtered.
 */
@WebServlet("/billing")
public class BillingServlet extends HttpServlet {

    private static final int PAGE_SIZE = 8;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("q");
        if (search == null) search = "";
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException ignored) {
            // Missing or invalid page param just falls back to page 1.
        }
        if (page < 1) page = 1;

        String likeTerm = "%" + search + "%";
        // Staff reading the reference off a printed receipt can paste it
        // straight in — "SDC000001" isn't a real column, so it's decoded
        // back to the row id and matched alongside the usual name search.
        Integer appointmentIdMatch = AppointmentValidator.parseAppointmentNumber(search);

        StringBuilder where = new StringBuilder(
                "a.total_amount IS NOT NULL AND (p.name LIKE ? OR d.name LIKE ?" +
                        (appointmentIdMatch != null ? " OR a.id = ?" : "") + ")");
        if (hasValue(dateFrom)) where.append(" AND a.appointment_date >= ?");
        if (hasValue(dateTo)) where.append(" AND a.appointment_date <= ?");
        String whereClause = where.toString();

        String countSql = "SELECT COUNT(*) FROM appointments a " +
                "JOIN patients p ON p.id = a.patient_id JOIN doctors d ON d.id = a.doctor_id WHERE " + whereClause;
        String revenueSql = "SELECT COALESCE(SUM(a.total_amount), 0) FROM appointments a " +
                "JOIN patients p ON p.id = a.patient_id JOIN doctors d ON d.id = a.doctor_id WHERE " + whereClause;
        String listSql = "SELECT a.id, a.appointment_date, a.consultation_fee, a.total_amount, " +
                "p.name AS patient_name, p.phone AS patient_phone, d.name AS doctor_name, " +
                "GROUP_CONCAT(aps.service_name ORDER BY aps.service_name SEPARATOR ', ') AS services " +
                "FROM appointments a " +
                "JOIN patients p ON p.id = a.patient_id JOIN doctors d ON d.id = a.doctor_id " +
                "LEFT JOIN appointment_services aps ON aps.appointment_id = a.id " +
                "WHERE " + whereClause + " " +
                "GROUP BY a.id ORDER BY a.appointment_date DESC, a.id DESC LIMIT ? OFFSET ?";

        List<Map<String, String>> billingList = new ArrayList<>();
        int totalCount = 0;
        BigDecimal totalRevenue = BigDecimal.ZERO;

        try (Connection conn = DBConnection.getConnection()) {

            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                bindFilters(ps, likeTerm, appointmentIdMatch, dateFrom, dateTo, 1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalCount = rs.getInt(1);
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(revenueSql)) {
                bindFilters(ps, likeTerm, appointmentIdMatch, dateFrom, dateTo, 1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalRevenue = rs.getBigDecimal(1);
                }
            }

            int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) PAGE_SIZE));
            if (page > totalPages) page = totalPages;
            int offset = (page - 1) * PAGE_SIZE;

            SimpleDateFormat dateFormat = new SimpleDateFormat("MMM d, yyyy");
            DecimalFormat money = new DecimalFormat("#,##0.00");

            try (PreparedStatement ps = conn.prepareStatement(listSql)) {
                int nextParam = bindFilters(ps, likeTerm, appointmentIdMatch, dateFrom, dateTo, 1);
                ps.setInt(nextParam++, PAGE_SIZE);
                ps.setInt(nextParam, offset);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> row = new LinkedHashMap<>();
                        int id = rs.getInt("id");
                        row.put("id", String.valueOf(id));
                        row.put("appointmentNumber", AppointmentValidator.formatAppointmentNumber(id));
                        row.put("patientName", rs.getString("patient_name"));
                        row.put("patientPhone", rs.getString("patient_phone"));
                        row.put("doctorName", rs.getString("doctor_name"));
                        row.put("date", dateFormat.format(rs.getDate("appointment_date")));
                        row.put("consultationFee", money.format(rs.getBigDecimal("consultation_fee")));
                        String services = rs.getString("services");
                        row.put("services", services == null ? "" : services);
                        row.put("total", money.format(rs.getBigDecimal("total_amount")));
                        billingList.add(row);
                    }
                }
            }

            request.setAttribute("billingList", billingList);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", PAGE_SIZE);
            request.setAttribute("searchQuery", search);
            request.setAttribute("dateFrom", dateFrom == null ? "" : dateFrom);
            request.setAttribute("dateTo", dateTo == null ? "" : dateTo);
            request.setAttribute("totalRevenue", money.format(totalRevenue));

        } catch (SQLException e) {
            throw new ServletException("Database error while loading billing list", e);
        }

        // Live search/pagination requests only need the table fragment re-rendered,
        // not the full page (sidebar, header, etc.) again.
        boolean isAjax = "1".equals(request.getParameter("ajax"));
        String target = isAjax ? "components/billing-table.jsp" : "billing.jsp";
        request.getRequestDispatcher(target).forward(request, response);
    }

    private static boolean hasValue(String s) {
        return s != null && !s.trim().isEmpty();
    }

    /** Binds the name-search term(s), the optional appointment-number match, and any date filters, in the same order they appear in whereClause. */
    private static int bindFilters(PreparedStatement ps, String likeTerm, Integer appointmentIdMatch,
                                    String dateFrom, String dateTo, int startIndex) throws SQLException {
        int i = startIndex;
        ps.setString(i++, likeTerm);
        ps.setString(i++, likeTerm);
        if (appointmentIdMatch != null) ps.setInt(i++, appointmentIdMatch);
        if (hasValue(dateFrom)) ps.setDate(i++, Date.valueOf(dateFrom.trim()));
        if (hasValue(dateTo)) ps.setDate(i++, Date.valueOf(dateTo.trim()));
        return i;
    }
}
