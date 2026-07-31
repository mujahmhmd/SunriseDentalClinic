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
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/staffs")
public class StaffServlet extends HttpServlet {

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

        String countSql = "SELECT COUNT(*) FROM users WHERE role = 'staff' AND (username LIKE ? OR name LIKE ?)";
        String listSql = "SELECT id, username, name, status, created_at FROM users " +
                "WHERE role = 'staff' AND (username LIKE ? OR name LIKE ?) " +
                "ORDER BY created_at DESC LIMIT ? OFFSET ?";

        List<Map<String, String>> staffList = new ArrayList<>();
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

            try (PreparedStatement ps = conn.prepareStatement(listSql)) {
                ps.setString(1, likeTerm);
                ps.setString(2, likeTerm);
                ps.setInt(3, PAGE_SIZE);
                ps.setInt(4, offset);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> row = new LinkedHashMap<>();
                        row.put("id", rs.getString("id"));
                        row.put("username", rs.getString("username"));
                        row.put("name", rs.getString("name"));
                        row.put("status", rs.getString("status"));
                        row.put("joined", dateFormat.format(rs.getTimestamp("created_at")));
                        staffList.add(row);
                    }
                }
            }

            request.setAttribute("staffList", staffList);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", PAGE_SIZE);
            request.setAttribute("searchQuery", search);

        } catch (SQLException e) {
            throw new ServletException("Database error while loading staff list", e);
        }

        // Live search/pagination requests only need the table fragment re-rendered,
        // not the full page (sidebar, header, etc.) again.
        boolean isAjax = "1".equals(request.getParameter("ajax"));
        String target = isAjax ? "components/staff-table.jsp" : "staffs.jsp";
        request.getRequestDispatcher(target).forward(request, response);
    }
}
