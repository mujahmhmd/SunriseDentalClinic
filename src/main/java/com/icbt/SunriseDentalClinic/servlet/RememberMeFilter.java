package com.icbt.SunriseDentalClinic.servlet;

import com.icbt.SunriseDentalClinic.util.RememberTokenUtil;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;

/**
 * Runs on every request. If there's no active session but a valid
 * "remember me" cookie exists, transparently re-establishes the session
 * (no re-entering credentials) — this is what makes a login survive a
 * server redeploy, since the plain HttpSession alone can't.
 */
@WebFilter("/*")
public class RememberMeFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;

        // Static assets don't need a session; skip the DB lookup for them.
        String uri = request.getRequestURI();
        if (uri.matches(".*\\.(css|js|png|jpg|jpeg|svg|ico|woff2?)$")) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        boolean alreadyLoggedIn = session != null && session.getAttribute("username") != null;

        if (!alreadyLoggedIn) {
            String token = readCookie(request, RememberTokenUtil.COOKIE_NAME);
            if (token != null) {
                try {
                    Map<String, String> user = RememberTokenUtil.validate(token);
                    if (user != null) {
                        HttpSession restored = request.getSession();
                        restored.setAttribute("username", user.get("username"));
                        restored.setAttribute("name", user.get("name"));
                        restored.setAttribute("role", user.get("role"));
                    }
                } catch (SQLException e) {
                    throw new ServletException("Database error while restoring remembered login", e);
                }
            }
        }

        chain.doFilter(req, res);
    }

    private String readCookie(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie cookie : cookies) {
            if (name.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }
        return null;
    }
}
