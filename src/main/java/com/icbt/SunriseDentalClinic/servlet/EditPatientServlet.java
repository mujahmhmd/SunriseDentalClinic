package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.util.PatientValidator;
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

@WebServlet("/editPatient")
public class EditPatientServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String sql = "SELECT id, name, date_of_birth, phone, email, nic, gender, address FROM patients WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    response.sendRedirect("patients");
                    return;
                }
                request.setAttribute("id", rs.getString("id"));
                request.setAttribute("name", rs.getString("name"));
                request.setAttribute("dateOfBirth", rs.getDate("date_of_birth").toString()); // yyyy-MM-dd, matches <input type="date">
                request.setAttribute("phone", rs.getString("phone"));
                request.setAttribute("email", rs.getString("email"));
                request.setAttribute("nic", rs.getString("nic"));
                request.setAttribute("gender", rs.getString("gender"));
                request.setAttribute("address", rs.getString("address"));
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while loading patient", e);
        }

        request.getRequestDispatcher("edit-patient.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String nic = request.getParameter("nic");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");

        String validationError = PatientValidator.validate(name, dateOfBirth, phone, email, nic, gender);
        if (validationError != null) {
            forwardWithError(request, response, validationError, id);
            return;
        }

        String updateSql = "UPDATE patients SET name = ?, date_of_birth = ?, phone = ?, email = ?, nic = ?, gender = ?, address = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setString(1, name.trim());
            ps.setString(2, dateOfBirth.trim());
            ps.setString(3, StaffValidator.normalizePhone(phone));
            ps.setString(4, email == null || email.trim().isEmpty() ? null : email.trim());
            ps.setString(5, nic == null || nic.trim().isEmpty() ? null : nic.trim());
            ps.setString(6, gender == null || gender.trim().isEmpty() ? null : gender.trim());
            ps.setString(7, address == null || address.trim().isEmpty() ? null : address.trim());
            ps.setString(8, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException("Database error while updating patient", e);
        }

        response.sendRedirect("patients?success=" + URLEncoder.encode("Patient details updated", "UTF-8"));
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error, String id)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("id", id);
        request.setAttribute("name", request.getParameter("name"));
        request.setAttribute("dateOfBirth", request.getParameter("dateOfBirth"));
        request.setAttribute("phone", request.getParameter("phone"));
        request.setAttribute("email", request.getParameter("email"));
        request.setAttribute("nic", request.getParameter("nic"));
        request.setAttribute("gender", request.getParameter("gender"));
        request.setAttribute("address", request.getParameter("address"));
        request.getRequestDispatcher("edit-patient.jsp").forward(request, response);
    }
}
