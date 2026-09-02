package com.icbt.SunriseDentalClinic.util;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Properties;

/**
 * Sends emails (forgot-password OTPs, appointment confirmations, bills)
 * through Brevo's transactional email REST API. Calls the HTTP API directly
 * with the JDK's built-in HttpClient (Java 11+) rather than pulling in a
 * mail/SDK dependency - this project already hand-builds small JSON
 * payloads elsewhere (e.g. PatientSearchServlet) instead of adding a
 * library for it.
 *
 * Configuration lives in src/main/resources/brevo.properties, which is
 * gitignored since it holds a live API key - see brevo.properties.example
 * for the template.
 */
public final class BrevoMailer {

    private static final String API_URL = "https://api.brevo.com/v3/smtp/email";
    private static final Properties CONFIG = loadConfig();

    private BrevoMailer() {
    }

    public static void sendOtpEmail(String toEmail, String toName, String otp) throws IOException, InterruptedException {
        String html = "<div style=\"font-family:sans-serif;font-size:15px;color:#1c1c1c;line-height:1.5\">"
                + "<p>Hi " + escapeHtml(toName) + ",</p>"
                + "<p>Use this code to reset your Sunrise Dental Clinic portal password. It expires in 5 minutes.</p>"
                + "<p style=\"font-size:28px;font-weight:700;letter-spacing:6px;margin:24px 0\">" + escapeHtml(otp) + "</p>"
                + "<p>If you didn't request this, you can safely ignore this email.</p>"
                + "</div>";
        send(toEmail, toName, "Your Sunrise Dental password reset code", html);
    }

    /** Booking confirmation, sent once an appointment is created - see EmailTemplates. */
    public static void sendAppointmentConfirmationEmail(String toEmail, String toName, String html) throws IOException, InterruptedException {
        send(toEmail, toName, "Your appointment at Sunrise Dental Clinic is confirmed", html);
    }

    /** Bill/receipt, sent once an appointment is marked Completed and paid - see EmailTemplates. */
    public static void sendBillEmail(String toEmail, String toName, String html) throws IOException, InterruptedException {
        send(toEmail, toName, "Your receipt from Sunrise Dental Clinic", html);
    }

    private static void send(String toEmail, String toName, String subject, String htmlContent)
            throws IOException, InterruptedException {

        String apiKey = CONFIG.getProperty("brevo.api.key", "");
        String senderEmail = CONFIG.getProperty("brevo.sender.email", "");
        String senderName = CONFIG.getProperty("brevo.sender.name", "Sunrise Dental Clinic");

        if (apiKey.isEmpty() || senderEmail.isEmpty()) {
            throw new IOException("Brevo isn't configured - check src/main/resources/brevo.properties.");
        }

        String json = "{"
                + "\"sender\":{\"name\":\"" + jsonEscape(senderName) + "\",\"email\":\"" + jsonEscape(senderEmail) + "\"},"
                + "\"to\":[{\"email\":\"" + jsonEscape(toEmail) + "\",\"name\":\"" + jsonEscape(toName) + "\"}],"
                + "\"subject\":\"" + jsonEscape(subject) + "\","
                + "\"htmlContent\":\"" + jsonEscape(htmlContent) + "\""
                + "}";

        HttpClient client = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(API_URL))
                .timeout(Duration.ofSeconds(15))
                .header("accept", "application/json")
                .header("api-key", apiKey)
                .header("content-type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(json))
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() >= 300) {
            throw new IOException("Brevo API returned " + response.statusCode() + ": " + response.body());
        }
    }

    private static Properties loadConfig() {
        Properties props = new Properties();
        try (InputStream in = BrevoMailer.class.getResourceAsStream("/brevo.properties")) {
            if (in != null) props.load(in);
        } catch (IOException e) {
            throw new RuntimeException("Failed to load brevo.properties", e);
        }
        return props;
    }

    private static String jsonEscape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }

    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}
