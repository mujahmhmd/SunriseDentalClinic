package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.util.BrevoMailer;
import com.icbt.SunriseDentalClinic.util.OtpUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Step 1 of "forgot password": email in, OTP out (emailed via Brevo).
 * Deliberately tells the user outright if no account has that email
 * (rather than the more guarded "if an account exists, we've sent a code"
 * wording other systems use) — that's a product choice, not an oversight:
 * simpler UX for a small clinic's own staff/admin accounts, at the cost of
 * letting someone probe which emails are registered.
 */
@WebServlet("/forgotPassword")
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            forwardWithError(request, response, "Enter your email address.", email);
            return;
        }

        int userId = -1;
        String name = null;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT id, name FROM users WHERE email = ? AND status = 'active'")) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    userId = rs.getInt("id");
                    name = rs.getString("name");
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Database error while looking up account for password reset", e);
        }

        if (userId == -1) {
            forwardWithError(request, response, "No account found with that email.", email);
            return;
        }

        try {
            String otp = OtpUtil.issue(userId);
            BrevoMailer.sendOtpEmail(email.trim(), name, otp);
        } catch (SQLException e) {
            throw new ServletException("Database error while issuing password reset code", e);
        } catch (Exception e) {
            // Brevo/network failure — don't leak the raw exception to the
            // user, but do log it so the actual cause (e.g. Brevo's IP
            // allowlist rejecting a request, as happened during setup) is
            // findable in Tomcat's logs rather than just "it didn't work".
            log("Failed to send password reset email to " + email, e);
            forwardWithError(request, response, "Couldn't send the reset email. Please try again.", email);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("resetUserId", userId);
        session.setAttribute("resetEmail", email.trim());
        session.removeAttribute("otpVerified");
        session.removeAttribute("verifiedOtp");

        response.sendRedirect("verify-otp.jsp");
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error, String email)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("email", email);
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }
}
