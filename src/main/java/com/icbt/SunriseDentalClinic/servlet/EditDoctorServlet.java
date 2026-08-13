package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.util.DoctorValidator;
import com.icbt.SunriseDentalClinic.util.StaffValidator;
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
import java.sql.Time;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/editDoctor")
public class EditDoctorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String sql = "SELECT id, name, nic, phone, address, slmc_reg_no, qualifications, " +
                "experience_years, consultation_fee FROM doctors WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("doctors");
                        return;
                    }
                    request.setAttribute("id", rs.getString("id"));
                    request.setAttribute("name", rs.getString("name"));
                    request.setAttribute("nic", rs.getString("nic"));
                    request.setAttribute("phone", rs.getString("phone"));
                    request.setAttribute("address", rs.getString("address"));
                    request.setAttribute("slmcRegNo", rs.getString("slmc_reg_no"));
                    request.setAttribute("qualifications", rs.getString("qualifications"));
                    Object years = rs.getObject("experience_years");
                    request.setAttribute("experienceYears", years == null ? "" : String.valueOf(years));
                    request.setAttribute("consultationFee", rs.getBigDecimal("consultation_fee").toPlainString());
                }
            }

            List<String> selected = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT specialization_id FROM doctor_specializations WHERE doctor_id = ?")) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        selected.add(rs.getString("specialization_id"));
                    }
                }
            }
            request.setAttribute("selectedSpecializations", selected.toArray(new String[0]));

            List<String> selectedDays = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT day_of_week, start_time, end_time FROM doctor_schedules WHERE doctor_id = ?")) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String day = rs.getString("day_of_week");
                        selectedDays.add(day);
                        request.setAttribute("start_" + day, rs.getTime("start_time").toString().substring(0, 5));
                        request.setAttribute("end_" + day, rs.getTime("end_time").toString().substring(0, 5));
                    }
                }
            }
            request.setAttribute("selectedDays", selectedDays.toArray(new String[0]));

        } catch (SQLException e) {
            throw new ServletException("Database error while loading doctor", e);
        }

        CreateDoctorServlet.loadSpecializations(request);
        request.getRequestDispatcher("edit-doctor.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String nic = request.getParameter("nic");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String slmcRegNo = request.getParameter("slmcRegNo");
        String qualifications = request.getParameter("qualifications");
        String experienceYears = request.getParameter("experienceYears");
        String consultationFee = request.getParameter("consultationFee");
        String[] specializationIds = request.getParameterValues("specializations");
        String[] days = request.getParameterValues("days");
        Map<String, String> startTimes = new HashMap<>();
        Map<String, String> endTimes = new HashMap<>();
        for (String day : DoctorValidator.DAYS) {
            startTimes.put(day, request.getParameter("start_" + day));
            endTimes.put(day, request.getParameter("end_" + day));
        }

        String validationError = DoctorValidator.validate(name, nic, phone, slmcRegNo,
                qualifications, experienceYears, consultationFee, specializationIds);
        if (validationError == null) {
            validationError = DoctorValidator.validateSchedule(days, startTimes, endTimes);
        }
        if (validationError != null) {
            forwardWithError(request, response, validationError, id);
            return;
        }

        String checkSql = "SELECT 1 FROM doctors WHERE slmc_reg_no = ? AND id <> ?";
        String updateSql = "UPDATE doctors SET name = ?, nic = ?, phone = ?, address = ?, slmc_reg_no = ?, " +
                "qualifications = ?, experience_years = ?, consultation_fee = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {

            // Excludes this doctor's own id so re-saving their unchanged
            // registration number isn't mistaken for a clash.
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, slmcRegNo.trim());
                ps.setString(2, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        forwardWithError(request, response, "That SLMC registration number is already in use.", id);
                        return;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, name.trim());
                ps.setString(2, nic.trim());
                ps.setString(3, StaffValidator.normalizePhone(phone));
                ps.setString(4, address == null || address.trim().isEmpty() ? null : address.trim());
                ps.setString(5, slmcRegNo.trim());
                ps.setString(6, qualifications.trim());
                ps.setObject(7, experienceYears == null || experienceYears.trim().isEmpty() ? null : Integer.parseInt(experienceYears.trim()));
                ps.setDouble(8, Double.parseDouble(consultationFee.trim()));
                ps.setString(9, id);
                ps.executeUpdate();
            }

            // Simplest correct way to sync a many-to-many set: clear and re-insert.
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM doctor_specializations WHERE doctor_id = ?")) {
                ps.setString(1, id);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO doctor_specializations (doctor_id, specialization_id) VALUES (?, ?)")) {
                for (String specializationId : specializationIds) {
                    ps.setString(1, id);
                    ps.setInt(2, Integer.parseInt(specializationId));
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            // Same clear-and-re-insert approach for the visiting-hours schedule.
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM doctor_schedules WHERE doctor_id = ?")) {
                ps.setString(1, id);
                ps.executeUpdate();
            }
            if (days != null && days.length > 0) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO doctor_schedules (doctor_id, day_of_week, start_time, end_time) VALUES (?, ?, ?, ?)")) {
                    for (String day : days) {
                        ps.setString(1, id);
                        ps.setString(2, day);
                        ps.setTime(3, Time.valueOf(startTimes.get(day) + ":00"));
                        ps.setTime(4, Time.valueOf(endTimes.get(day) + ":00"));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while updating doctor", e);
        }

        response.sendRedirect("doctors?success=" + URLEncoder.encode("Doctor details updated", "UTF-8"));
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error, String id)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("id", id);
        request.setAttribute("name", request.getParameter("name"));
        request.setAttribute("nic", request.getParameter("nic"));
        request.setAttribute("phone", request.getParameter("phone"));
        request.setAttribute("address", request.getParameter("address"));
        request.setAttribute("slmcRegNo", request.getParameter("slmcRegNo"));
        request.setAttribute("qualifications", request.getParameter("qualifications"));
        request.setAttribute("experienceYears", request.getParameter("experienceYears"));
        request.setAttribute("consultationFee", request.getParameter("consultationFee"));
        String[] selected = request.getParameterValues("specializations");
        request.setAttribute("selectedSpecializations", selected == null ? new String[0] : selected);
        String[] days = request.getParameterValues("days");
        request.setAttribute("selectedDays", days == null ? new String[0] : days);
        for (String day : DoctorValidator.DAYS) {
            request.setAttribute("start_" + day, request.getParameter("start_" + day));
            request.setAttribute("end_" + day, request.getParameter("end_" + day));
        }
        CreateDoctorServlet.loadSpecializations(request);
        request.getRequestDispatcher("edit-doctor.jsp").forward(request, response);
    }
}
