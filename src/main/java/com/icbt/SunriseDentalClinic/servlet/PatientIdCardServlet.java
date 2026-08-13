package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.util.PatientValidator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;

@WebServlet("/patientIdCard")
public class PatientIdCardServlet extends HttpServlet {

    private static final DateTimeFormatter DOB_DISPLAY_FORMAT = DateTimeFormatter.ofPattern("MMM d, yyyy");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String sql = "SELECT id, name, date_of_birth, phone, nic, gender, address FROM patients WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    response.sendRedirect("patients");
                    return;
                }
                int patientId = rs.getInt("id");
                request.setAttribute("patientCode", PatientValidator.formatPatientId(patientId));
                request.setAttribute("name", rs.getString("name"));

                LocalDate dob = rs.getDate("date_of_birth").toLocalDate();
                request.setAttribute("dobDisplay", dob.format(DOB_DISPLAY_FORMAT));
                request.setAttribute("age", String.valueOf(Period.between(dob, LocalDate.now()).getYears()));

                request.setAttribute("phone", rs.getString("phone"));
                request.setAttribute("nic", rs.getString("nic"));
                request.setAttribute("gender", rs.getString("gender"));
                request.setAttribute("address", rs.getString("address"));
            }
        } catch (SQLException e) {
            throw new ServletException("Database error while loading patient ID card", e);
        }

        request.getRequestDispatcher("patient-id-card.jsp").forward(request, response);
    }
}
