package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Undoes a Completed or Cancelled appointment back to Scheduled - the fix
 * for "staff marked this complete by mistake". Reopening a Completed
 * appointment also clears whatever was billed on it (appointment_services
 * rows, consultation_fee, total_amount) rather than carrying stale charges
 * forward; if it gets completed again, payment is confirmed fresh through
 * the normal popup.
 *
 * Available to Staff as well as Admin (not gated in RememberMeFilter) -
 * blocking it entirely would leave a mis-completed appointment stuck
 * whenever no admin happens to be around. In exchange, who reopened it,
 * when, why, and what the cleared total was get recorded so it's still
 * reviewable afterward, instead of being a silent edit to a billing record.
 */
@WebServlet("/reopenAppointment")
public class ReopenAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String reason = request.getParameter("reason");
        HttpSession session = request.getSession(false);
        String reopenedBy = session != null ? (String) session.getAttribute("name") : null;

        try (Connection conn = DBConnection.getConnection()) {

            BigDecimal previousTotal = null;
            try (PreparedStatement ps = conn.prepareStatement("SELECT total_amount FROM appointments WHERE id = ?")) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) previousTotal = rs.getBigDecimal("total_amount");
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM appointment_services WHERE appointment_id = ?")) {
                ps.setString(1, id);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE appointments SET status = 'Scheduled', consultation_fee = NULL, total_amount = NULL, " +
                            "reopened_by = ?, reopened_at = NOW(), reopen_reason = ?, reopen_previous_total = ? " +
                            "WHERE id = ? AND status IN ('Completed', 'Cancelled')")) {
                ps.setString(1, reopenedBy);
                ps.setString(2, reason == null || reason.trim().isEmpty() ? null : reason.trim());
                ps.setBigDecimal(3, previousTotal);
                ps.setString(4, id);
                ps.executeUpdate();
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while reopening appointment", e);
        }

        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }
}
