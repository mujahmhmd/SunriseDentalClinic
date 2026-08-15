package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.util.OtpUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

/** Step 2 of "forgot password": checks the code emailed in step 1. */
@WebServlet("/verifyOtp")
public class VerifyOtpServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("resetUserId") : null;
        if (userId == null) {
            // Session expired, or this page was reached without going
            // through step 1 first - start over rather than error out.
            response.sendRedirect("forgot-password.jsp");
            return;
        }

        String otp = request.getParameter("otp");
        boolean valid;
        try {
            valid = OtpUtil.verify(userId, otp);
        } catch (SQLException e) {
            throw new ServletException("Database error while verifying password reset code", e);
        }

        if (!valid) {
            request.setAttribute("error", "That code is incorrect or has expired.");
            request.getRequestDispatcher("verify-otp.jsp").forward(request, response);
            return;
        }

        session.setAttribute("otpVerified", true);
        session.setAttribute("verifiedOtp", otp.trim());
        response.sendRedirect("reset-password.jsp");
    }
}
