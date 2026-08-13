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
 * Undoes a Completed or Cancelled appointment back to Scheduled — the fix
 * for "staff marked this complete by mistake". Reopening a Completed
 * appointment also clears whatever was billed on it (appointment_services
 * rows, consultation_fee, total_amount) rather than carrying stale charges
 * forward; if it gets completed again, payment is confirmed fresh through
 * the normal popup.
 */
@WebServlet("/reopenAppointment")
public class ReopenAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");

        try (Connection conn = DBConnection.getConnection()) {

            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM appointment_services WHERE appointment_id = ?")) {
                ps.setString(1, id);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE appointments SET status = 'Scheduled', consultation_fee = NULL, total_amount = NULL " +
                            "WHERE id = ? AND status IN ('Completed', 'Cancelled')")) {
                ps.setString(1, id);
                ps.executeUpdate();
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while reopening appointment", e);
        }

        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }
}
