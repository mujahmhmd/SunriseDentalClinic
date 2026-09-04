package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.testsupport.DisplayNameReporter;
import com.icbt.SunriseDentalClinic.util.BrevoMailer;
import com.icbt.SunriseDentalClinic.util.OtpUtil;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.MockedStatic;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * ForgotPasswordServlet's own job is just: look the email up, and either
 * issue+email a code or explain why not. OtpUtil.issue() and
 * BrevoMailer.sendOtpEmail() are stubbed rather than re-simulated - the
 * point here is proving THIS servlet's control flow, not re-testing OtpUtil
 * (a DB-backed collaborator) or actually calling Brevo's real API (which a
 * unit test must never do).
 */
@DisplayName("ForgotPasswordServlet - step 1: email in, OTP out")
@ExtendWith(DisplayNameReporter.class)
public class ForgotPasswordServletTest {

    private ForgotPasswordServlet servlet;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private RequestDispatcher dispatcher;
    private Connection connection;
    private PreparedStatement preparedStatement;
    private ResultSet resultSet;

    @BeforeEach
    void setUp() throws Exception {
        servlet = new ForgotPasswordServlet();
        // ForgotPasswordServlet's Brevo-failure branch calls the inherited
        // GenericServlet.log(...), which needs a real ServletConfig/Context
        // behind it - without this, log() itself throws
        // "ServletConfig has not been initialized" (a container normally
        // does this init() call for you before any request ever reaches doPost).
        ServletConfig servletConfig = mock(ServletConfig.class);
        ServletContext servletContext = mock(ServletContext.class);
        when(servletConfig.getServletContext()).thenReturn(servletContext);
        servlet.init(servletConfig);

        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        dispatcher = mock(RequestDispatcher.class);
        connection = mock(Connection.class);
        preparedStatement = mock(PreparedStatement.class);
        resultSet = mock(ResultSet.class);

        when(request.getSession()).thenReturn(session);
        when(request.getRequestDispatcher("forgot-password.jsp")).thenReturn(dispatcher);
        when(connection.prepareStatement(anyString())).thenReturn(preparedStatement);
        when(preparedStatement.executeQuery()).thenReturn(resultSet);
    }

    @Test
    @DisplayName("A blank email is rejected before any database lookup happens")
    public void blankEmail_showsEnterEmailError() throws Exception {
        when(request.getParameter("email")).thenReturn("  ");

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class)) {
            servlet.doPost(request, response);

            verify(request).setAttribute("error", "Enter your email address.");
            verify(dispatcher).forward(request, response);
            db.verifyNoInteractions();
        }
    }

    @Test
    @DisplayName("An email with no matching active account shows \"No account found\"")
    public void emailNotFound_showsNoAccountError() throws Exception {
        when(request.getParameter("email")).thenReturn("nobody@example.com");
        when(resultSet.next()).thenReturn(false);

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class)) {
            db.when(DBConnection::getConnection).thenReturn(connection);

            servlet.doPost(request, response);

            verify(request).setAttribute("error", "No account found with that email.");
            verify(dispatcher).forward(request, response);
        }
    }

    @Test
    @DisplayName("A matching email issues a code, emails it, and lands on the verify-code screen")
    public void emailFound_issuesCodeAndRedirectsToVerifyOtp() throws Exception {
        when(request.getParameter("email")).thenReturn(" jane@example.com ");
        when(resultSet.next()).thenReturn(true);
        when(resultSet.getInt("id")).thenReturn(5);
        when(resultSet.getString("name")).thenReturn("Jane Perera");

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class);
             MockedStatic<OtpUtil> otpUtil = mockStatic(OtpUtil.class);
             MockedStatic<BrevoMailer> brevoMailer = mockStatic(BrevoMailer.class)) {
            db.when(DBConnection::getConnection).thenReturn(connection);
            otpUtil.when(() -> OtpUtil.issue(5)).thenReturn("123456");

            servlet.doPost(request, response);

            brevoMailer.verify(() -> BrevoMailer.sendOtpEmail("jane@example.com", "Jane Perera", "123456"));
            verify(session).setAttribute("resetUserId", 5);
            verify(session).setAttribute("resetEmail", "jane@example.com");
            verify(session).removeAttribute("otpVerified");
            verify(session).removeAttribute("verifiedOtp");
            verify(response).sendRedirect("verify-otp.jsp");
        }
    }

    @Test
    @DisplayName("A Brevo/network failure shows a friendly error instead of leaking the exception")
    public void emailSendFails_showsCouldntSendError() throws Exception {
        when(request.getParameter("email")).thenReturn("jane@example.com");
        when(resultSet.next()).thenReturn(true);
        when(resultSet.getInt("id")).thenReturn(5);
        when(resultSet.getString("name")).thenReturn("Jane Perera");

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class);
             MockedStatic<OtpUtil> otpUtil = mockStatic(OtpUtil.class);
             MockedStatic<BrevoMailer> brevoMailer = mockStatic(BrevoMailer.class)) {
            db.when(DBConnection::getConnection).thenReturn(connection);
            otpUtil.when(() -> OtpUtil.issue(5)).thenReturn("123456");
            brevoMailer.when(() -> BrevoMailer.sendOtpEmail(anyString(), anyString(), anyString()))
                    .thenThrow(new IOException("Brevo API returned 401"));

            servlet.doPost(request, response);

            verify(request).setAttribute("error", "Couldn't send the reset email. Please try again.");
            verify(dispatcher).forward(request, response);
            verify(response, never()).sendRedirect(anyString());
        }
    }
}
