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
import java.util.ArrayList;
import java.util.List;

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
                    Object fee = rs.getObject("consultation_fee");
                    request.setAttribute("consultationFee", fee == null ? "" : String.valueOf(fee));
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

        String validationError = DoctorValidator.validate(name, nic, phone, slmcRegNo,
                qualifications, experienceYears, consultationFee, specializationIds);
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
                ps.setObject(8, consultationFee == null || consultationFee.trim().isEmpty() ? null : Double.parseDouble(consultationFee.trim()));
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
        CreateDoctorServlet.loadSpecializations(request);
        request.getRequestDispatcher("edit-doctor.jsp").forward(request, response);
    }
}
