package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.testsupport.DisplayNameReporter;
import com.icbt.SunriseDentalClinic.util.OtpUtil;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.MockedStatic;

import java.sql.Connection;
import java.sql.PreparedStatement;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * ResetPasswordServlet re-checks the OTP a second time (step 2 already
 * verified it, but the code could expire in the gap before the password is
 * actually changed) before writing the new password. OtpUtil is stubbed
 * rather than re-simulating its DB-backed logic - the interesting behavior
 * to pin down here is this servlet's own control flow around that
 * re-check, the session guard, and the validation rules.
 */
@DisplayName("ResetPasswordServlet - step 3: setting the new password")
@ExtendWith(DisplayNameReporter.class)
public class ResetPasswordServletTest {

    private ResetPasswordServlet servlet;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private RequestDispatcher dispatcher;
    private Connection connection;
    private PreparedStatement preparedStatement;

    @BeforeEach
    void setUp() throws Exception {
        servlet = new ResetPasswordServlet();
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        dispatcher = mock(RequestDispatcher.class);
        connection = mock(Connection.class);
        preparedStatement = mock(PreparedStatement.class);

        when(connection.prepareStatement(anyString())).thenReturn(preparedStatement);
    }

    /** Puts the session in the state step 2 (VerifyOtpServlet) leaves it in. */
    private void givenOtpAlreadyVerified() {
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("resetUserId")).thenReturn(9);
        when(session.getAttribute("otpVerified")).thenReturn(Boolean.TRUE);
        when(session.getAttribute("verifiedOtp")).thenReturn("123456");
    }

    @Test
    @DisplayName("Reaching this page without having verified a code sends back to step 1")
    public void otpNotVerified_redirectsToForgotPassword() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        servlet.doPost(request, response);

        verify(response).sendRedirect("forgot-password.jsp");
    }

    @Test
    @DisplayName("A blank new password is rejected before touching the database")
    public void blankNewPassword_showsError() throws Exception {
        givenOtpAlreadyVerified();
        when(request.getParameter("newPassword")).thenReturn("");
        when(request.getRequestDispatcher("reset-password.jsp")).thenReturn(dispatcher);

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class)) {
            servlet.doPost(request, response);

            verify(request).setAttribute("error", "Enter a new password.");
            verify(dispatcher).forward(request, response);
            db.verifyNoInteractions();
        }
    }

    @Test
    @DisplayName("A password missing a required character class is rejected")
    public void weakPassword_showsError() throws Exception {
        givenOtpAlreadyVerified();
        when(request.getParameter("newPassword")).thenReturn("weakpassword");
        when(request.getParameter("confirmPassword")).thenReturn("weakpassword");
        when(request.getRequestDispatcher("reset-password.jsp")).thenReturn(dispatcher);

        servlet.doPost(request, response);

        verify(request).setAttribute("error",
                "Password needs at least 6 characters, with an uppercase letter, a lowercase letter, a number and a special character.");
        verify(dispatcher).forward(request, response);
    }

    @Test
    @DisplayName("New Password and Confirm New Password not matching is rejected")
    public void mismatchedConfirmation_showsError() throws Exception {
        givenOtpAlreadyVerified();
        when(request.getParameter("newPassword")).thenReturn("Welcome@123");
        when(request.getParameter("confirmPassword")).thenReturn("Different@123");
        when(request.getRequestDispatcher("reset-password.jsp")).thenReturn(dispatcher);

        servlet.doPost(request, response);

        verify(request).setAttribute("error", "Passwords don't match.");
        verify(dispatcher).forward(request, response);
    }

    @Test
    @DisplayName("If the code expires in the gap before submitting, the password is not changed")
    public void otpExpiredBetweenVerifyAndSubmit_showsExpiredError() throws Exception {
        givenOtpAlreadyVerified();
        when(request.getParameter("newPassword")).thenReturn("Welcome@123");
        when(request.getParameter("confirmPassword")).thenReturn("Welcome@123");
        when(request.getRequestDispatcher("reset-password.jsp")).thenReturn(dispatcher);

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class);
             MockedStatic<OtpUtil> otpUtil = mockStatic(OtpUtil.class)) {
            db.when(DBConnection::getConnection).thenReturn(connection);
            otpUtil.when(() -> OtpUtil.verify(9, "123456")).thenReturn(false);

            servlet.doPost(request, response);

            verify(request).setAttribute("error", "That code has expired. Start over and request a new one.");
            verify(dispatcher).forward(request, response);
            verify(preparedStatement, never()).executeUpdate();
        }
    }

    @Test
    @DisplayName("A valid, matching, strong password updates the account and redirects to Login with a success message")
    public void success_updatesPasswordAndRedirectsToLogin() throws Exception {
        givenOtpAlreadyVerified();
        when(request.getParameter("newPassword")).thenReturn("Welcome@123");
        when(request.getParameter("confirmPassword")).thenReturn("Welcome@123");

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class);
             MockedStatic<OtpUtil> otpUtil = mockStatic(OtpUtil.class)) {
            db.when(DBConnection::getConnection).thenReturn(connection);
            otpUtil.when(() -> OtpUtil.verify(9, "123456")).thenReturn(true);

            servlet.doPost(request, response);

            verify(preparedStatement).setInt(2, 9);
            verify(preparedStatement).executeUpdate();
            otpUtil.verify(() -> OtpUtil.markUsed(9));
            verify(session).removeAttribute("resetUserId");
            verify(session).removeAttribute("otpVerified");
            verify(session).removeAttribute("verifiedOtp");
            verify(response).sendRedirect(startsWith("login.jsp?success="));
        }
    }
}
