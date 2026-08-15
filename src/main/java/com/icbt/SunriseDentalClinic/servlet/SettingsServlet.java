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
import java.sql.ResultSet;
import java.sql.SQLException;

/** The signed-in user's own account page - update their username or password. */
@WebServlet("/settings")
public class SettingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Object sessionUsername = request.getSession().getAttribute("username");

        if (sessionUsername != null) {
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement("SELECT username FROM users WHERE username = ?")) {
                ps.setString(1, (String) sessionUsername);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("username", rs.getString("username"));
                    }
                }
            } catch (SQLException e) {
                throw new ServletException("Database error while loading settings", e);
            }
        }

        request.getRequestDispatcher("settings.jsp").forward(request, response);
    }
}
