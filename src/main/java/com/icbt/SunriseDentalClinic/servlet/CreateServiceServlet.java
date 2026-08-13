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

@WebServlet("/createService")
public class CreateServiceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("create-service.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String price = request.getParameter("price");
        String description = request.getParameter("description");

        String validationError = ServiceValidator.validate(name, price, description);
        if (validationError != null) {
            forwardWithError(request, response, validationError);
            return;
        }

        String checkSql = "SELECT 1 FROM services WHERE name = ?";
        String insertSql = "INSERT INTO services (name, price, description, status) VALUES (?, ?, ?, 'active')";

        try (Connection conn = DBConnection.getConnection()) {

            // Checked explicitly (rather than relying on the UNIQUE constraint
            // failing) so we can show a friendly message instead of a raw SQL error.
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, name.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        forwardWithError(request, response, "A service with that name already exists.");
                        return;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, name.trim());
                ps.setDouble(2, Double.parseDouble(price.trim()));
                ps.setString(3, description == null || description.trim().isEmpty() ? null : description.trim());
                ps.executeUpdate();
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while creating service", e);
        }

        response.sendRedirect("services?success=" + URLEncoder.encode("Service added", "UTF-8"));
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("name", request.getParameter("name"));
        request.setAttribute("price", request.getParameter("price"));
        request.setAttribute("description", request.getParameter("description"));
        request.getRequestDispatcher("create-service.jsp").forward(request, response);
    }
}
