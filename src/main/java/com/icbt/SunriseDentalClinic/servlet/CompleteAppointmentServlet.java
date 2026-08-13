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
 * Marks a Scheduled appointment Completed directly. This is the seam where
 * the planned payment step (Complete -> "Processing Payment" popup -> paid
 * -> Completed, plus attaching the Service(s) actually performed) will slot
 * in later; nothing sets 'Processing Payment' yet.
 */
@WebServlet("/completeAppointment")
public class CompleteAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");

        // Only a Scheduled appointment can be completed — guards against a
        // stale/duplicate click flipping an already Cancelled/Completed row.
        String sql = "UPDATE appointments SET status = 'Completed' WHERE id = ? AND status = 'Scheduled'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException("Database error while completing appointment", e);
        }

        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }
}
