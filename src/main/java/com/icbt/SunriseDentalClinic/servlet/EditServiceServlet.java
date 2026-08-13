package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.util.ServiceValidator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/editService")
public class EditServiceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String sql = "SELECT id, name, price, description FROM services WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    response.sendRedirect("services");
                    return;
                }
                request.setAttribute("id", rs.getString("id"));
                request.setAttribute("name", rs.getString("name"));
                request.setAttribute("price", rs.getBigDecimal("price").toPlainString());
                request.setAttribute("description", rs.getString("description"));
            }
        } catch (SQLException e) {
            throw new ServletException("Database error while loading service", e);
        }

        request.getRequestDispatcher("edit-service.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String price = request.getParameter("price");
        String description = request.getParameter("description");

        String validationError = ServiceValidator.validate(name, price, description);
        if (validationError != null) {
            forwardWithError(request, response, validationError, id);
            return;
        }

        String checkSql = "SELECT 1 FROM services WHERE name = ? AND id <> ?";
        String updateSql = "UPDATE services SET name = ?, price = ?, description = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {

            // Excludes this service's own id so re-saving its unchanged name
            // isn't mistaken for a clash.
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, name.trim());
                ps.setString(2, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        forwardWithError(request, response, "A service with that name already exists.", id);
                        return;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, name.trim());
                ps.setDouble(2, Double.parseDouble(price.trim()));
                ps.setString(3, description == null || description.trim().isEmpty() ? null : description.trim());
                ps.setString(4, id);
                ps.executeUpdate();
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while updating service", e);
        }

        response.sendRedirect("services?success=" + URLEncoder.encode("Service details updated", "UTF-8"));
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error, String id)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("id", id);
        request.setAttribute("name", request.getParameter("name"));
        request.setAttribute("price", request.getParameter("price"));
        request.setAttribute("description", request.getParameter("description"));
        request.getRequestDispatcher("edit-service.jsp").forward(request, response);
    }
}
