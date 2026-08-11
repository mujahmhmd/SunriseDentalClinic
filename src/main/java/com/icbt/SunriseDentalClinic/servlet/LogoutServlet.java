package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.util.RememberTokenUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // false = don't create a new session just to destroy it; if the user
        // has no session, there's nothing to log out of.
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (RememberTokenUtil.COOKIE_NAME.equals(cookie.getName())) {
                    // Revoke server-side so a copy of the old cookie can't be
                    // replayed later, then expire it in the browser too.
                    try {
                        RememberTokenUtil.revoke(cookie.getValue());
                    } catch (SQLException e) {
                        throw new ServletException("Database error while revoking remember-me token", e);
                    }
                    Cookie expired = new Cookie(RememberTokenUtil.COOKIE_NAME, "");
                    expired.setHttpOnly(true);
                    expired.setPath(request.getContextPath() + "/");
                    expired.setMaxAge(0);
                    response.addCookie(expired);
                    break;
                }
            }
        }

        response.sendRedirect("login.jsp");
    }
}
