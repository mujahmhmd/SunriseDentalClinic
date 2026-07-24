package com.icbt.SunriseDentalClinic;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/hello")
public class SunriseDentalClinicServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");
        response.getWriter().println("<h1>Hello from SunriseDentalClinicServlet running on Tomcat!</h1>"
                + "<p>This page is served by: <code>src/main/java/com/icbt/SunriseDentalClinic/SunriseDentalClinicServlet.java</code></p>"
                + "<p><a href=\"./\">&larr; Back to Home (index.jsp)</a></p>");
    }
}