package com.icbt.SunriseDentalClinic.servlet;

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

import static org.mockito.Mockito.*;

/**
 * VerifyOtpServlet delegates the actual check entirely to
 * OtpUtil.verify(userId, otp) - a single static call - so stubbing that one
 * method is enough to exercise every branch of the servlet's own logic
 * without touching a database at all.
 */
@DisplayName("VerifyOtpServlet - step 2: checking the emailed code")
@ExtendWith(DisplayNameReporter.class)
public class VerifyOtpServletTest {

    private VerifyOtpServlet servlet;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;

    @BeforeEach
    void setUp() {
        servlet = new VerifyOtpServlet();
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
    }

    @Test
    @DisplayName("No \"resetUserId\" in session (reached this page directly) sends back to step 1")
    public void noResetSessionInFlight_redirectsToForgotPassword() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        servlet.doPost(request, response);

        verify(response).sendRedirect("forgot-password.jsp");
        verifyNoInteractions(session);
    }

    @Test
    @DisplayName("A correct code marks the session verified and moves on to Reset Password")
    public void correctOtp_marksVerifiedAndRedirectsToResetPassword() throws Exception {
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("resetUserId")).thenReturn(7);
        when(request.getParameter("otp")).thenReturn("123456");

        try (MockedStatic<OtpUtil> otpUtil = mockStatic(OtpUtil.class)) {
            otpUtil.when(() -> OtpUtil.verify(7, "123456")).thenReturn(true);

            servlet.doPost(request, response);

            verify(session).setAttribute("otpVerified", true);
            verify(session).setAttribute("verifiedOtp", "123456");
            verify(response).sendRedirect("reset-password.jsp");
        }
    }

    @Test
    @DisplayName("An incorrect or expired code re-shows the form with an error, without advancing")
    public void incorrectOtp_showsError() throws Exception {
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("resetUserId")).thenReturn(7);
        when(request.getParameter("otp")).thenReturn("000000");
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("verify-otp.jsp")).thenReturn(dispatcher);

        try (MockedStatic<OtpUtil> otpUtil = mockStatic(OtpUtil.class)) {
            otpUtil.when(() -> OtpUtil.verify(anyInt(), anyString())).thenReturn(false);

            servlet.doPost(request, response);

            verify(request).setAttribute("error", "That code is incorrect or has expired.");
            verify(dispatcher).forward(request, response);
            verify(session, never()).setAttribute(eq("otpVerified"), any());
            verify(response, never()).sendRedirect(anyString());
        }
    }
}
