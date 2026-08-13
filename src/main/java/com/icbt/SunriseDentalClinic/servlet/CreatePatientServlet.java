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
import java.sql.SQLException;

@WebServlet("/createPatient")
public class CreatePatientServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String phone = request.getParameter("phone");
        String nic = request.getParameter("nic");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");

        String validationError = PatientValidator.validate(name, dateOfBirth, phone, nic, gender);
        if (validationError != null) {
            forwardWithError(request, response, validationError);
            return;
        }

        String insertSql = "INSERT INTO patients (name, date_of_birth, phone, nic, gender, address) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setString(1, name.trim());
            ps.setString(2, dateOfBirth.trim());
            ps.setString(3, StaffValidator.normalizePhone(phone));
            ps.setString(4, nic == null || nic.trim().isEmpty() ? null : nic.trim());
            ps.setString(5, gender == null || gender.trim().isEmpty() ? null : gender.trim());
            ps.setString(6, address == null || address.trim().isEmpty() ? null : address.trim());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException("Database error while creating patient", e);
        }

        response.sendRedirect("patients?success=" + URLEncoder.encode("Patient added", "UTF-8"));
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("name", request.getParameter("name"));
        request.setAttribute("dateOfBirth", request.getParameter("dateOfBirth"));
        request.setAttribute("phone", request.getParameter("phone"));
        request.setAttribute("nic", request.getParameter("nic"));
        request.setAttribute("gender", request.getParameter("gender"));
        request.setAttribute("address", request.getParameter("address"));
        request.getRequestDispatcher("create-patient.jsp").forward(request, response);
    }
}
