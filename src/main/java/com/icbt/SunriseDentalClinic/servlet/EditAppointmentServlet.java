package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.util.AppointmentValidator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;

@WebServlet("/editAppointment")
public class EditAppointmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String sql = "SELECT a.id, a.patient_id, a.doctor_id, a.appointment_date, a.appointment_time, " +
                "a.reason_for_visit, a.notes, p.name AS patient_name, p.phone AS patient_phone " +
                "FROM appointments a JOIN patients p ON p.id = a.patient_id WHERE a.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    response.sendRedirect("appointments");
                    return;
                }
                request.setAttribute("id", rs.getString("id"));
                request.setAttribute("patientId", rs.getString("patient_id"));
                request.setAttribute("patientDisplay", rs.getString("patient_name") + " — " + rs.getString("patient_phone"));
                request.setAttribute("doctorId", rs.getString("doctor_id"));
                request.setAttribute("appointmentDate", rs.getDate("appointment_date").toString());
                request.setAttribute("appointmentTime", rs.getTime("appointment_time").toString().substring(0, 5));
                request.setAttribute("reasonForVisit", rs.getString("reason_for_visit"));
                request.setAttribute("notes", rs.getString("notes"));
            }
        } catch (SQLException e) {
            throw new ServletException("Database error while loading appointment", e);
        }

        CreateAppointmentServlet.loadDoctors(request);
        request.getRequestDispatcher("edit-appointment.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String patientId = request.getParameter("patientId");
        String doctorId = request.getParameter("doctorId");
        String appointmentDate = request.getParameter("appointmentDate");
        String appointmentTime = request.getParameter("appointmentTime");
        String reasonForVisit = request.getParameter("reasonForVisit");
        String notes = request.getParameter("notes");

        String validationError = AppointmentValidator.validate(patientId, doctorId,
                appointmentDate, appointmentTime, reasonForVisit, notes);
        if (validationError != null) {
            forwardWithError(request, response, validationError, id);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            if (!CreateAppointmentServlet.patientExists(conn, patientId)) {
                forwardWithError(request, response, "Selected patient couldn't be found — search and pick one again.", id);
                return;
            }
            if (!CreateAppointmentServlet.doctorExists(conn, doctorId)) {
                forwardWithError(request, response, "Selected doctor couldn't be found.", id);
                return;
            }
            if (CreateAppointmentServlet.slotTaken(conn, doctorId, appointmentDate, appointmentTime, id)) {
                forwardWithError(request, response, "That doctor already has an appointment at this date and time.", id);
                return;
            }
            if (CreateAppointmentServlet.patientDoubleBooked(conn, patientId, appointmentDate, appointmentTime, id)) {
                forwardWithError(request, response, "This patient already has another appointment at this date and time.", id);
                return;
            }

            String updateSql = "UPDATE appointments SET patient_id = ?, doctor_id = ?, appointment_date = ?, " +
                    "appointment_time = ?, reason_for_visit = ?, notes = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, Integer.parseInt(patientId.trim()));
                ps.setInt(2, Integer.parseInt(doctorId.trim()));
                ps.setDate(3, Date.valueOf(appointmentDate.trim()));
                ps.setTime(4, Time.valueOf(appointmentTime.trim() + ":00"));
                ps.setString(5, reasonForVisit == null || reasonForVisit.trim().isEmpty() ? null : reasonForVisit.trim());
                ps.setString(6, notes == null || notes.trim().isEmpty() ? null : notes.trim());
                ps.setString(7, id);
                ps.executeUpdate();
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while updating appointment", e);
        }

        response.sendRedirect("appointments?success=" + URLEncoder.encode("Appointment updated", "UTF-8"));
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error, String id)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("id", id);
        request.setAttribute("patientId", request.getParameter("patientId"));
        request.setAttribute("patientDisplay", CreateAppointmentServlet.buildPatientDisplay(request.getParameter("patientId")));
        request.setAttribute("doctorId", request.getParameter("doctorId"));
        request.setAttribute("appointmentDate", request.getParameter("appointmentDate"));
        request.setAttribute("appointmentTime", request.getParameter("appointmentTime"));
        request.setAttribute("reasonForVisit", request.getParameter("reasonForVisit"));
        request.setAttribute("notes", request.getParameter("notes"));
        CreateAppointmentServlet.loadDoctors(request);
        request.getRequestDispatcher("edit-appointment.jsp").forward(request, response);
    }
}
