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
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * Runs on every request. Two responsibilities, both session-based and
 * intentionally kept in one filter rather than two:
 *
 * 1. If there's no active session but a valid "remember me" cookie exists,
 *    transparently re-establishes the session (no re-entering credentials)
 *    — this is what makes a login survive a server redeploy, since the
 *    plain HttpSession alone can't.
 * 2. Blocks Staff accounts from admin-only pages/actions (Staffs, Services,
 *    Billing in full; just the delete action on Doctors) even via a direct
 *    URL, not just by hiding the sidebar links/buttons. This has to run
 *    *after* step 1 resolves the role for a remembered-but-not-yet-session-
 *    restored request — doing it in a second @WebFilter would work most of
 *    the time, but the servlet spec doesn't guarantee ordering between two
 *    annotation-declared filters, so it's kept here instead where the
 *    ordering is guaranteed by being the same method call.
 */
@WebFilter("/*")
public class RememberMeFilter implements Filter {

    // Keep in sync with the admin-only nav items/buttons in
    // components/sidebar.jsp and components/doctor-table.jsp. Doctors itself
    // is staff-visible (they book appointments against it) — only deleting a
    // doctor record is admin-only.
    //
    // Includes both the servlet route (e.g. "/staffs") AND the .jsp file it
    // forwards to (e.g. "/staffs.jsp") — Tomcat serves any .jsp under
    // webapp/ directly by URL regardless of @WebServlet mappings, so
    // blocking only the route left the raw page (and its AJAX table
    // fragment) reachable straight from the browser, just without data.
    private static final Set<String> ADMIN_ONLY_PATHS = new HashSet<>(Arrays.asList(
            "/staffs", "/staffs.jsp", "/createStaff", "/create-staff.jsp",
            "/editStaff", "/edit-staff.jsp", "/deleteStaff", "/toggleStaffStatus",
            "/components/staff-table.jsp",
            "/deleteDoctor",
            "/services", "/services.jsp", "/createService", "/create-service.jsp",
            "/editService", "/edit-service.jsp", "/deleteService", "/toggleServiceStatus",
            "/components/service-table.jsp",
            "/billing", "/billing.jsp", "/components/billing-table.jsp"
    ));

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

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
                        session = restored;
                    }
                } catch (SQLException e) {
                    throw new ServletException("Database error while restoring remembered login", e);
                }
            }
        }

        String path = uri.substring(request.getContextPath().length());
        boolean loggedIn = session != null && session.getAttribute("username") != null;
        if (loggedIn && ADMIN_ONLY_PATHS.contains(path) && !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/dashboard?error="
                    + URLEncoder.encode("You don't have access to that page.", "UTF-8"));
            return;
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
