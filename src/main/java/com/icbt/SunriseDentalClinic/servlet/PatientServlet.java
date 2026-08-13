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
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/patients")
public class PatientServlet extends HttpServlet {

    private static final int PAGE_SIZE = 8;
    private static final DateTimeFormatter DOB_DISPLAY_FORMAT = DateTimeFormatter.ofPattern("MMM d, yyyy");

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

        String countSql = "SELECT COUNT(*) FROM patients WHERE name LIKE ? OR phone LIKE ? OR nic LIKE ?";
        String listSql = "SELECT id, name, date_of_birth, phone, nic, gender FROM patients " +
                "WHERE name LIKE ? OR phone LIKE ? OR nic LIKE ? " +
                "ORDER BY created_at DESC LIMIT ? OFFSET ?";

        List<Map<String, String>> patientList = new ArrayList<>();
        int totalCount = 0;

        try (Connection conn = DBConnection.getConnection()) {

            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setString(1, likeTerm);
                ps.setString(2, likeTerm);
                ps.setString(3, likeTerm);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalCount = rs.getInt(1);
                }
            }

            int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) PAGE_SIZE));
            if (page > totalPages) page = totalPages;
            int offset = (page - 1) * PAGE_SIZE;

            try (PreparedStatement ps = conn.prepareStatement(listSql)) {
                ps.setString(1, likeTerm);
                ps.setString(2, likeTerm);
                ps.setString(3, likeTerm);
                ps.setInt(4, PAGE_SIZE);
                ps.setInt(5, offset);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> row = new LinkedHashMap<>();
                        row.put("id", rs.getString("id"));
                        row.put("name", rs.getString("name"));

                        LocalDate dob = rs.getDate("date_of_birth").toLocalDate();
                        row.put("dobDisplay", dob.format(DOB_DISPLAY_FORMAT));
                        row.put("age", String.valueOf(Period.between(dob, LocalDate.now()).getYears()));

                        row.put("phone", rs.getString("phone"));
                        row.put("nic", rs.getString("nic"));
                        row.put("gender", rs.getString("gender"));
                        patientList.add(row);
                    }
                }
            }

            request.setAttribute("patientList", patientList);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", PAGE_SIZE);
            request.setAttribute("searchQuery", search);

        } catch (SQLException e) {
            throw new ServletException("Database error while loading patient list", e);
        }

        // Live search/pagination requests only need the table fragment re-rendered,
        // not the full page (sidebar, header, etc.) again.
        boolean isAjax = "1".equals(request.getParameter("ajax"));
        String target = isAjax ? "components/patient-table.jsp" : "patients.jsp";
        request.getRequestDispatcher(target).forward(request, response);
    }
}
