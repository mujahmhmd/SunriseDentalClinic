package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.util.OtpUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.regex.Pattern;

/** Step 3 of "forgot password": set a new password once the code has been verified. */
@WebServlet("/resetPassword")
public class ResetPasswordServlet extends HttpServlet {

    // Same strength rule as StaffValidator's password check - kept as its
    // own copy rather than shared, matching how the other validators in
    // this app each keep their own pattern copies too.
    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9]).{6,}$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("resetUserId") : null;
        Boolean otpVerified = session != null ? (Boolean) session.getAttribute("otpVerified") : null;
        String verifiedOtp = session != null ? (String) session.getAttribute("verifiedOtp") : null;

        if (userId == null || otpVerified == null || !otpVerified || verifiedOtp == null) {
            response.sendRedirect("forgot-password.jsp");
            return;
        }

        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        String validationError = validate(newPassword, confirmPassword);
        if (validationError != null) {
            request.setAttribute("error", validationError);
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            // Re-checked here, not just at step 2 - closes the window where
            // the code could otherwise expire (or already be used) between
            // being verified and the password actually being changed.
            if (!OtpUtil.verify(userId, verifiedOtp)) {
                request.setAttribute("error", "That code has expired. Start over and request a new one.");
                request.getRequestDispatcher("reset-password.jsp").forward(request, response);
                return;
            }

            String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET password = ? WHERE id = ?")) {
                ps.setString(1, hashedPassword);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

            OtpUtil.markUsed(userId);

        } catch (SQLException e) {
            throw new ServletException("Database error while resetting password", e);
        }

        session.removeAttribute("resetUserId");
        session.removeAttribute("resetEmail");
        session.removeAttribute("otpVerified");
        session.removeAttribute("verifiedOtp");

        response.sendRedirect("login.jsp?success=" + URLEncoder.encode("You have successfully reset your password.", "UTF-8"));
    }

    private static String validate(String newPassword, String confirmPassword) {
        if (newPassword == null || newPassword.isEmpty()) {
            return "Enter a new password.";
        }
        if (!PASSWORD_PATTERN.matcher(newPassword).matches()) {
            return "Password needs at least 6 characters, with an uppercase letter, a lowercase letter, a number and a special character.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "Passwords don't match.";
        }
        return null;
    }
}
