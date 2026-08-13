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
import java.sql.Statement;
import java.sql.Time;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/createDoctor")
public class CreateDoctorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        loadSpecializations(request);
        request.getRequestDispatcher("create-doctor.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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
            forwardWithError(request, response, validationError);
            return;
        }

        String checkSql = "SELECT 1 FROM doctors WHERE slmc_reg_no = ?";
        String insertSql = "INSERT INTO doctors (name, nic, phone, address, slmc_reg_no, qualifications, " +
                "experience_years, consultation_fee, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'active')";

        try (Connection conn = DBConnection.getConnection()) {

            // Checked explicitly (rather than relying on the UNIQUE constraint
            // failing) so we can show a friendly message instead of a raw SQL error.
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, slmcRegNo.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        forwardWithError(request, response, "That SLMC registration number is already in use.");
                        return;
                    }
                }
            }

            int doctorId;
            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, name.trim());
                ps.setString(2, nic.trim());
                ps.setString(3, StaffValidator.normalizePhone(phone));
                ps.setString(4, address == null || address.trim().isEmpty() ? null : address.trim());
                ps.setString(5, slmcRegNo.trim());
                ps.setString(6, qualifications.trim());
                ps.setObject(7, experienceYears == null || experienceYears.trim().isEmpty() ? null : Integer.parseInt(experienceYears.trim()));
                ps.setDouble(8, Double.parseDouble(consultationFee.trim()));
                ps.executeUpdate();

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    keys.next();
                    doctorId = keys.getInt(1);
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO doctor_specializations (doctor_id, specialization_id) VALUES (?, ?)")) {
                for (String specializationId : specializationIds) {
                    ps.setInt(1, doctorId);
                    ps.setInt(2, Integer.parseInt(specializationId));
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            if (days != null && days.length > 0) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO doctor_schedules (doctor_id, day_of_week, start_time, end_time) VALUES (?, ?, ?, ?)")) {
                    for (String day : days) {
                        ps.setInt(1, doctorId);
                        ps.setString(2, day);
                        ps.setTime(3, Time.valueOf(startTimes.get(day) + ":00"));
                        ps.setTime(4, Time.valueOf(endTimes.get(day) + ":00"));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while creating doctor", e);
        }

        response.sendRedirect("doctors?success=" + URLEncoder.encode("Doctor added", "UTF-8"));
    }

    static void loadSpecializations(HttpServletRequest request) throws ServletException {
        List<Map<String, String>> specializations = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id, name FROM specializations ORDER BY name");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<>();
                row.put("id", rs.getString("id"));
                row.put("name", rs.getString("name"));
                specializations.add(row);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error while loading specializations", e);
        }
        request.setAttribute("specializations", specializations);
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
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
        loadSpecializations(request);
        request.getRequestDispatcher("create-doctor.jsp").forward(request, response);
    }
}
