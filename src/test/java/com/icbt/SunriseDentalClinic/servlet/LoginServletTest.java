package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.db.DBConnection;
import com.icbt.SunriseDentalClinic.testsupport.DisplayNameReporter;
import com.icbt.SunriseDentalClinic.util.RememberTokenUtil;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mindrot.jbcrypt.BCrypt;
import org.mockito.MockedStatic;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * LoginServlet has no dependency-injection seam - it calls
 * DBConnection.getConnection() and RememberTokenUtil.issue() directly, both
 * static. Mockito 5's inline mock maker (bundled in mockito-core, no extra
 * dependency needed) can mock static methods, which is what makes this
 * servlet testable at all without changing production code: DBConnection is
 * stubbed to return a mocked Connection/PreparedStatement/ResultSet chain,
 * and RememberTokenUtil.issue() is stubbed directly (its own internal DB
 * write is RememberTokenUtil's own concern, not LoginServlet's, so it's
 * treated here as a collaborator to stub, not something to re-simulate).
 */
@DisplayName("LoginServlet - username/password sign-in")
@ExtendWith(DisplayNameReporter.class)
public class LoginServletTest {

    private LoginServlet servlet;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private Connection connection;
    private PreparedStatement preparedStatement;
    private ResultSet resultSet;

    @BeforeEach
    void setUp() throws Exception {
        servlet = new LoginServlet();
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        connection = mock(Connection.class);
        preparedStatement = mock(PreparedStatement.class);
        resultSet = mock(ResultSet.class);

        when(connection.prepareStatement(anyString())).thenReturn(preparedStatement);
        when(preparedStatement.executeQuery()).thenReturn(resultSet);
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/SunriseDentalClinic");
    }

    /** A real bcrypt hash of {@code plainPassword}, exactly as stored in the users table. */
    private static String hash(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt());
    }

    @Test
    @DisplayName("Correct credentials on an active account start a session and redirect to the dashboard")
    public void correctCredentials_activeAccount_redirectsToDashboard() throws Exception {
        when(request.getParameter("username")).thenReturn("admin");
        when(request.getParameter("password")).thenReturn("Correct@123");
        when(request.getParameter("remember")).thenReturn(null);

        when(resultSet.next()).thenReturn(true);
        when(resultSet.getString("password")).thenReturn(hash("Correct@123"));
        when(resultSet.getString("status")).thenReturn("active");
        when(resultSet.getString("name")).thenReturn("Clinic Admin");
        when(resultSet.getString("role")).thenReturn("admin");
        when(resultSet.getInt("id")).thenReturn(1);

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class);
             MockedStatic<RememberTokenUtil> rememberToken = mockStatic(RememberTokenUtil.class)) {
            db.when(DBConnection::getConnection).thenReturn(connection);
            rememberToken.when(() -> RememberTokenUtil.issue(anyInt(), anyInt())).thenReturn("dummy-token");

            servlet.doPost(request, response);

            verify(session).setAttribute("username", "admin");
            verify(session).setAttribute("name", "Clinic Admin");
            verify(session).setAttribute("role", "admin");
            verify(response).addCookie(any(Cookie.class));
            verify(response).sendRedirect("dashboard");
        }
    }

    @Test
    @DisplayName("\"Keep me logged in\" unchecked issues a 1-day remember-me token")
    public void rememberMeUnchecked_issuesOneDayToken() throws Exception {
        when(request.getParameter("username")).thenReturn("admin");
        when(request.getParameter("password")).thenReturn("Correct@123");
        when(request.getParameter("remember")).thenReturn(null);

        when(resultSet.next()).thenReturn(true);
        when(resultSet.getString("password")).thenReturn(hash("Correct@123"));
        when(resultSet.getString("status")).thenReturn("active");

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class);
             MockedStatic<RememberTokenUtil> rememberToken = mockStatic(RememberTokenUtil.class)) {
            db.when(DBConnection::getConnection).thenReturn(connection);
            rememberToken.when(() -> RememberTokenUtil.issue(anyInt(), anyInt())).thenReturn("dummy-token");

            servlet.doPost(request, response);

            rememberToken.verify(() -> RememberTokenUtil.issue(anyInt(), eq(1)));
        }
    }

    @Test
    @DisplayName("\"Keep me logged in\" checked issues a 7-day remember-me token")
    public void rememberMeChecked_issuesSevenDayToken() throws Exception {
        when(request.getParameter("username")).thenReturn("admin");
        when(request.getParameter("password")).thenReturn("Correct@123");
        when(request.getParameter("remember")).thenReturn("on");

        when(resultSet.next()).thenReturn(true);
        when(resultSet.getString("password")).thenReturn(hash("Correct@123"));
        when(resultSet.getString("status")).thenReturn("active");

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class);
             MockedStatic<RememberTokenUtil> rememberToken = mockStatic(RememberTokenUtil.class)) {
            db.when(DBConnection::getConnection).thenReturn(connection);
            rememberToken.when(() -> RememberTokenUtil.issue(anyInt(), anyInt())).thenReturn("dummy-token");

            servlet.doPost(request, response);

            rememberToken.verify(() -> RememberTokenUtil.issue(anyInt(), eq(7)));
        }
    }

    @Test
    @DisplayName("A wrong password shows \"Invalid username or password.\" and re-shows the login form")
    public void wrongPassword_showsInvalidCredentialsError() throws Exception {
        when(request.getParameter("username")).thenReturn("admin");
        when(request.getParameter("password")).thenReturn("WrongPassword");
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("login.jsp")).thenReturn(dispatcher);

        when(resultSet.next()).thenReturn(true);
        when(resultSet.getString("password")).thenReturn(hash("Correct@123"));

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class)) {
            db.when(DBConnection::getConnection).thenReturn(connection);

            servlet.doPost(request, response);

            verify(request).setAttribute("error", "Invalid username or password.");
            verify(dispatcher).forward(request, response);
            verify(response, never()).sendRedirect(anyString());
        }
    }

    @Test
    @DisplayName("A username that doesn't exist shows the same \"Invalid username or password.\" error")
    public void usernameNotFound_showsInvalidCredentialsError() throws Exception {
        when(request.getParameter("username")).thenReturn("nobody");
        when(request.getParameter("password")).thenReturn("whatever");
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("login.jsp")).thenReturn(dispatcher);

        when(resultSet.next()).thenReturn(false);

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class)) {
            db.when(DBConnection::getConnection).thenReturn(connection);

            servlet.doPost(request, response);

            verify(request).setAttribute("error", "Invalid username or password.");
            verify(dispatcher).forward(request, response);
        }
    }

    @Test
    @DisplayName("Correct credentials on a deactivated account are rejected before starting a session")
    public void correctCredentials_deactivatedAccount_showsDeactivatedError() throws Exception {
        when(request.getParameter("username")).thenReturn("oldstaff");
        when(request.getParameter("password")).thenReturn("Correct@123");
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("login.jsp")).thenReturn(dispatcher);

        when(resultSet.next()).thenReturn(true);
        when(resultSet.getString("password")).thenReturn(hash("Correct@123"));
        when(resultSet.getString("status")).thenReturn("inactive");

        try (MockedStatic<DBConnection> db = mockStatic(DBConnection.class)) {
            db.when(DBConnection::getConnection).thenReturn(connection);

            servlet.doPost(request, response);

            verify(request).setAttribute("error", "This account has been deactivated.");
            verify(dispatcher).forward(request, response);
            verify(session, never()).setAttribute(eq("username"), any());
            verify(response, never()).sendRedirect(anyString());
        }
    }
}
