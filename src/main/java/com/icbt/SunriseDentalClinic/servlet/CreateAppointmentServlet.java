package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.util.AppointmentValidator;
import com.icbt.SunriseDentalClinic.util.BrevoMailer;
import com.icbt.SunriseDentalClinic.util.EmailTemplates;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/createAppointment")
public class CreateAppointmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        loadDoctors(request);
        request.getRequestDispatcher("create-appointment.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String patientId = request.getParameter("patientId");
        String doctorId = request.getParameter("doctorId");
        String appointmentDate = request.getParameter("appointmentDate");
        String appointmentTime = request.getParameter("appointmentTime");
        String reasonForVisit = request.getParameter("reasonForVisit");
        String notes = request.getParameter("notes");

        String validationError = AppointmentValidator.validate(patientId, doctorId,
                appointmentDate, appointmentTime, reasonForVisit, notes);
        if (validationError != null) {
            forwardWithError(request, response, validationError);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            if (!patientExists(conn, patientId)) {
                forwardWithError(request, response, "Selected patient couldn't be found - search and pick one again.");
                return;
            }
            if (!doctorExists(conn, doctorId)) {
                forwardWithError(request, response, "Selected doctor couldn't be found.");
                return;
            }
            if (slotTaken(conn, doctorId, appointmentDate, appointmentTime, null)) {
                forwardWithError(request, response, "That doctor already has an appointment at this date and time.");
                return;
            }
            if (patientDoubleBooked(conn, patientId, appointmentDate, appointmentTime, null)) {
                forwardWithError(request, response, "This patient already has another appointment at this date and time.");
                return;
            }

            String insertSql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, " +
                    "appointment_time, reason_for_visit, notes, status) VALUES (?, ?, ?, ?, ?, ?, 'Scheduled')";
            int appointmentId;
            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, Integer.parseInt(patientId.trim()));
                ps.setInt(2, Integer.parseInt(doctorId.trim()));
                ps.setDate(3, Date.valueOf(appointmentDate.trim()));
                ps.setTime(4, Time.valueOf(appointmentTime.trim() + ":00"));
                ps.setString(5, reasonForVisit == null || reasonForVisit.trim().isEmpty() ? null : reasonForVisit.trim());
                ps.setString(6, notes == null || notes.trim().isEmpty() ? null : notes.trim());
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    keys.next();
                    appointmentId = keys.getInt(1);
                }
            }

            // Best-effort - a booking is still valid even if the confirmation
            // email fails to send (e.g. Brevo/network hiccup, or the patient
            // just doesn't have an email on file), so this never blocks the redirect.
            try {
                sendConfirmationEmail(conn, appointmentId, Integer.parseInt(patientId.trim()),
                        Integer.parseInt(doctorId.trim()), appointmentDate.trim(), appointmentTime.trim(), reasonForVisit);
            } catch (Exception e) {
                log("Failed to send appointment confirmation email for appointment " + appointmentId, e);
            }

            response.sendRedirect("appointmentReceipt?id=" + appointmentId + "&justBooked=1");
            return;

        } catch (SQLException e) {
            throw new ServletException("Database error while creating appointment", e);
        }
    }

    static void loadDoctors(HttpServletRequest request) throws ServletException {
        List<Map<String, String>> doctors = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT id, name FROM doctors WHERE status = 'active' ORDER BY name");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<>();
                row.put("id", rs.getString("id"));
                row.put("name", rs.getString("name"));
                doctors.add(row);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error while loading doctors", e);
        }
        request.setAttribute("doctors", doctors);
    }

    static boolean patientExists(Connection conn, String patientId) throws SQLException {
        try {
            try (PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM patients WHERE id = ?")) {
                ps.setInt(1, Integer.parseInt(patientId.trim()));
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (NumberFormatException e) {
            return false;
        }
    }

    static boolean doctorExists(Connection conn, String doctorId) throws SQLException {
        try {
            try (PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM doctors WHERE id = ? AND status = 'active'")) {
                ps.setInt(1, Integer.parseInt(doctorId.trim()));
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * @param excludeAppointmentId when editing, the appointment's own id (so it
     *                             doesn't collide with itself); null when creating
     */
    static boolean slotTaken(Connection conn, String doctorId, String appointmentDate,
                              String appointmentTime, String excludeAppointmentId) throws SQLException {
        String sql = "SELECT 1 FROM appointments WHERE doctor_id = ? AND appointment_date = ? " +
                "AND appointment_time = ? AND status <> 'Cancelled'" +
                (excludeAppointmentId != null ? " AND id <> ?" : "");
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(doctorId.trim()));
            ps.setDate(2, Date.valueOf(appointmentDate.trim()));
            ps.setTime(3, Time.valueOf(appointmentTime.trim() + ":00"));
            if (excludeAppointmentId != null) {
                ps.setInt(4, Integer.parseInt(excludeAppointmentId.trim()));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * A patient can't be in two places at once - checked separately from
     * slotTaken (which is per-doctor) since this catches the same patient
     * booked with a *different* doctor at the same date/time.
     *
     * @param excludeAppointmentId when editing, the appointment's own id (so it
     *                             doesn't collide with itself); null when creating
     */
    static boolean patientDoubleBooked(Connection conn, String patientId, String appointmentDate,
                                        String appointmentTime, String excludeAppointmentId) throws SQLException {
        String sql = "SELECT 1 FROM appointments WHERE patient_id = ? AND appointment_date = ? " +
                "AND appointment_time = ? AND status <> 'Cancelled'" +
                (excludeAppointmentId != null ? " AND id <> ?" : "");
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(patientId.trim()));
            ps.setDate(2, Date.valueOf(appointmentDate.trim()));
            ps.setTime(3, Time.valueOf(appointmentTime.trim() + ":00"));
            if (excludeAppointmentId != null) {
                ps.setInt(4, Integer.parseInt(excludeAppointmentId.trim()));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** No-op if the patient has no email on file - see the class-level comment on the caller. */
    private void sendConfirmationEmail(Connection conn, int appointmentId, int patientId, int doctorId,
                                        String appointmentDate, String appointmentTime, String reasonForVisit)
            throws SQLException, IOException, InterruptedException {

        String patientName = null;
        String patientEmail = null;
        try (PreparedStatement ps = conn.prepareStatement("SELECT name, email FROM patients WHERE id = ?")) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    patientName = rs.getString("name");
                    patientEmail = rs.getString("email");
                }
            }
        }
        if (patientEmail == null || patientEmail.trim().isEmpty()) {
            return;
        }

        String doctorName = null;
        try (PreparedStatement ps = conn.prepareStatement("SELECT name FROM doctors WHERE id = ?")) {
            ps.setInt(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) doctorName = rs.getString("name");
            }
        }

        String formattedDate = LocalDate.parse(appointmentDate).format(DateTimeFormatter.ofPattern("EEEE, MMM d, yyyy"));
        String formattedTime = LocalTime.parse(appointmentTime).format(DateTimeFormatter.ofPattern("h:mm a"));
        String reason = reasonForVisit == null || reasonForVisit.trim().isEmpty() ? "General visit" : reasonForVisit.trim();

        String html = EmailTemplates.appointmentConfirmation(patientName,
                AppointmentValidator.formatAppointmentNumber(appointmentId), doctorName, formattedDate, formattedTime, reason);
        BrevoMailer.sendAppointmentConfirmationEmail(patientEmail.trim(), patientName, html);
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("patientId", request.getParameter("patientId"));
        request.setAttribute("patientDisplay", buildPatientDisplay(request.getParameter("patientId")));
        request.setAttribute("doctorId", request.getParameter("doctorId"));
        request.setAttribute("appointmentDate", request.getParameter("appointmentDate"));
        request.setAttribute("appointmentTime", request.getParameter("appointmentTime"));
        request.setAttribute("reasonForVisit", request.getParameter("reasonForVisit"));
        request.setAttribute("notes", request.getParameter("notes"));
        loadDoctors(request);
        request.getRequestDispatcher("create-appointment.jsp").forward(request, response);
    }

    /** Re-fetches "Name - Phone" for the search box so a validation error doesn't blank out the pick. */
    static String buildPatientDisplay(String patientId) throws ServletException {
        if (patientId == null || patientId.trim().isEmpty()) return "";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT name, phone FROM patients WHERE id = ?")) {
            ps.setInt(1, Integer.parseInt(patientId.trim()));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("name") + " - " + rs.getString("phone");
                }
            }
        } catch (SQLException | NumberFormatException e) {
            return "";
        }
        return "";
    }
}
