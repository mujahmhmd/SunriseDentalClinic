package com.icbt.SunriseDentalClinic.util;

import java.util.List;
import java.util.Map;

/**
 * Builds the HTML bodies for the appointment-confirmation and billing
 * emails, styled to read like the printable receipt
 * (appointment-receipt.jsp) so what lands in an inbox matches what's
 * printed at the front desk. Table-based layout with inline styles only -
 * no Tailwind/external CSS or flexbox, since email clients (Outlook
 * especially) don't reliably support either.
 */
public final class EmailTemplates {

    private static final String INK = "#1c2b28";
    private static final String MUTED = "#6b7a76";
    private static final String BORDER = "#e3e8e6";
    private static final String BRAND = "#0f3d33";
    private static final String BRAND_MUTED = "#cfe0dc";

    private EmailTemplates() {
    }

    public static String appointmentConfirmation(String patientName, String appointmentNumber, String doctorName,
                                                   String date, String time, String reason) {
        StringBuilder html = new StringBuilder();
        html.append(shellOpen("Appointment Confirmation", appointmentNumber));
        html.append(greeting(patientName, "Your appointment has been scheduled. Here are the details:"));
        html.append(detailsOpen());
        html.append(row("Doctor", "Dr. " + esc(doctorName)));
        html.append(row("Date", esc(date)));
        html.append(row("Time", esc(time)));
        html.append(row("Reason for Visit", esc(reason)));
        html.append(detailsClose());
        html.append(footer("Thank you for choosing Sunrise Dental Clinic - we look forward to seeing you soon!"));
        html.append(shellClose());
        return html.toString();
    }

    public static String bill(String patientName, String appointmentNumber, String doctorName, String date,
                               String consultationFee, List<Map<String, String>> services, String total) {
        StringBuilder html = new StringBuilder();
        html.append(shellOpen("Payment Receipt", appointmentNumber));
        html.append(greeting(patientName, "Your visit is complete. Here's a copy of your bill:"));
        html.append(detailsOpen());
        html.append(row("Doctor", "Dr. " + esc(doctorName)));
        html.append(row("Date", esc(date)));
        html.append(divider());
        html.append(row("Consultation Fee", "Rs. " + esc(consultationFee)));
        if (services != null) {
            for (Map<String, String> service : services) {
                html.append(row(esc(service.get("name")), "Rs. " + esc(service.get("price"))));
            }
        }
        html.append(totalRow("Total Paid", "Rs. " + esc(total)));
        html.append(detailsClose());
        html.append(footer("Thank you for visiting Sunrise Dental Clinic!"));
        html.append(shellClose());
        return html.toString();
    }

    private static String shellOpen(String heading, String appointmentNumber) {
        return "<div style=\"font-family:Arial,Helvetica,sans-serif;max-width:480px;margin:0 auto;padding:24px\">"
                + "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" "
                + "style=\"border-collapse:collapse;background:" + BRAND + ";border-radius:16px 16px 0 0\">"
                + "<tr><td style=\"padding:20px 24px\">"
                + "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\"><tr>"
                + "<td>"
                + "<p style=\"margin:0;color:#ffffff;font-size:15px;font-weight:600\">Sunrise Dental Clinic</p>"
                + "<p style=\"margin:2px 0 0;color:" + BRAND_MUTED + ";font-size:12px\">" + esc(heading) + "</p>"
                + "</td>"
                + "<td style=\"text-align:right\">"
                + "<p style=\"margin:0;color:" + BRAND_MUTED + ";font-size:11px\">Appointment No.</p>"
                + "<p style=\"margin:2px 0 0;color:#ffffff;font-size:14px;font-weight:600\">" + esc(appointmentNumber) + "</p>"
                + "</td>"
                + "</tr></table>"
                + "</td></tr></table>"
                + "<div style=\"background:#ffffff;border:1px solid " + BORDER + ";border-top:none;"
                + "border-radius:0 0 16px 16px;padding:24px\">";
    }

    private static String shellClose() {
        return "</div></div>";
    }

    private static String greeting(String name, String intro) {
        return "<p style=\"margin:0 0 14px;color:" + INK + ";font-size:14px\">Hi " + esc(name) + ",</p>"
                + "<p style=\"margin:0 0 20px;color:" + INK + ";font-size:14px\">" + esc(intro) + "</p>";
    }

    private static String detailsOpen() {
        return "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"border-collapse:collapse\">";
    }

    private static String detailsClose() {
        return "</table>";
    }

    private static String row(String label, String value) {
        return "<tr>"
                + "<td style=\"padding:6px 0;color:" + MUTED + ";font-size:13px\">" + label + "</td>"
                + "<td style=\"padding:6px 0;color:" + INK + ";font-size:13px;text-align:right\">" + value + "</td>"
                + "</tr>";
    }

    private static String totalRow(String label, String value) {
        return "<tr>"
                + "<td style=\"padding:12px 0 0;color:" + INK + ";font-size:14px;font-weight:700\">" + label + "</td>"
                + "<td style=\"padding:12px 0 0;color:" + INK + ";font-size:14px;font-weight:700;text-align:right\">" + value + "</td>"
                + "</tr>";
    }

    private static String divider() {
        return "<tr><td colspan=\"2\" style=\"padding:8px 0;border-top:1px dashed " + BORDER + "\"></td></tr>";
    }

    private static String footer(String message) {
        return "<p style=\"margin:24px 0 0;padding-top:16px;border-top:1px dashed " + BORDER + ";"
                + "color:" + INK + ";font-size:13px;text-align:center\">" + esc(message) + "</p>";
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}
