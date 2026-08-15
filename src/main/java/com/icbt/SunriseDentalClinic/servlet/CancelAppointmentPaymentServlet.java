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
import java.sql.SQLException;

/**
 * Backs out of the payment popup without charging anything - the appointment
 * goes back to Scheduled so it isn't left stuck in Processing Payment.
 */
@WebServlet("/cancelAppointmentPayment")
public class CancelAppointmentPaymentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String sql = "UPDATE appointments SET status = 'Scheduled' WHERE id = ? AND status = 'Processing Payment'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException("Database error while cancelling appointment payment", e);
        }

        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }
}
