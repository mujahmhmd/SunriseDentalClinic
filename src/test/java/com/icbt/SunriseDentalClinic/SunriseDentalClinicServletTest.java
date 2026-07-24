package com.icbt.SunriseDentalClinic;

import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.io.PrintWriter;
import java.io.StringWriter;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.junit.Test;

public class SunriseDentalClinicServletTest {

    @Test
    public void doGet_writesGreetingHtml() throws Exception {
        SunriseDentalClinicServlet servlet = new SunriseDentalClinicServlet();

        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        StringWriter stringWriter = new StringWriter();
        PrintWriter writer = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(writer);

        servlet.doGet(request, response);
        writer.flush();

        assertTrue(stringWriter.toString().contains("Hello from SunriseDentalClinicServlet"));
    }
}