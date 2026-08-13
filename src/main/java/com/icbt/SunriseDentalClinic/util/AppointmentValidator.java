package com.icbt.SunriseDentalClinic.util;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Server-side mirror of assets/js/appointment-form-validation.js. The JS
 * gives instant inline feedback; this is the actual source of truth since a
 * request can always bypass the browser's JS.
 */
public final class AppointmentValidator {

    // Matches the "SDC000001" reference printed on a receipt, typed or
    // pasted back in when searching for it — case-insensitive and tolerant
    // of the zero-padding, same reasoning as PatientValidator's patient-code pattern.
    private static final Pattern APPOINTMENT_NUMBER_PATTERN = Pattern.compile("^SDC0*([1-9][0-9]*)$", Pattern.CASE_INSENSITIVE);

    /**
     * Bookable slots within clinic hours (9 AM-5 PM), 30 minutes apart, last
     * slot at 4:30 PM so a visit has room to run before closing.
     * {form value "HH:mm", display label}.
     */
    public static final String[][] TIME_SLOTS = {
            {"09:00", "9:00 AM"}, {"09:30", "9:30 AM"}, {"10:00", "10:00 AM"}, {"10:30", "10:30 AM"},
            {"11:00", "11:00 AM"}, {"11:30", "11:30 AM"}, {"12:00", "12:00 PM"}, {"12:30", "12:30 PM"},
            {"13:00", "1:00 PM"}, {"13:30", "1:30 PM"}, {"14:00", "2:00 PM"}, {"14:30", "2:30 PM"},
            {"15:00", "3:00 PM"}, {"15:30", "3:30 PM"}, {"16:00", "4:00 PM"}, {"16:30", "4:30 PM"}
    };

    private AppointmentValidator() {
    }

    /** @return the first validation error found, or null if everything's valid */
    public static String validate(String patientId, String doctorId, String appointmentDate,
                                   String appointmentTime, String reasonForVisit, String notes) {

        if (patientId == null || patientId.trim().isEmpty()) {
            return "Select a patient from the search results.";
        }
        if (doctorId == null || doctorId.trim().isEmpty()) {
            return "Select a doctor.";
        }
        if (appointmentDate == null || appointmentDate.trim().isEmpty()) {
            return "Select an appointment date.";
        }
        LocalDate date;
        try {
            date = LocalDate.parse(appointmentDate.trim());
        } catch (DateTimeParseException e) {
            return "Enter a valid appointment date.";
        }
        if (date.isBefore(LocalDate.now())) {
            return "Appointment date can't be in the past.";
        }
        if (appointmentTime == null || !isValidTimeSlot(appointmentTime.trim())) {
            return "Select a valid appointment time.";
        }
        if (reasonForVisit != null && reasonForVisit.trim().length() > 255) {
            return "Reason for visit must be under 255 characters.";
        }
        if (notes != null && notes.trim().length() > 500) {
            return "Notes must be under 500 characters.";
        }

        return null;
    }

    private static boolean isValidTimeSlot(String time) {
        for (String[] slot : TIME_SLOTS) {
            if (slot[0].equals(time)) return true;
        }
        return false;
    }

    /** Patient-facing booking reference — just the row id, zero-padded and prefixed. */
    public static String formatAppointmentNumber(int id) {
        return String.format("SDC%06d", id);
    }

    /** @return the appointment row id if {@code query} looks like a printed appointment number, otherwise null */
    public static Integer parseAppointmentNumber(String query) {
        if (query == null) return null;
        Matcher matcher = APPOINTMENT_NUMBER_PATTERN.matcher(query.trim());
        if (!matcher.matches()) return null;
        try {
            return Integer.parseInt(matcher.group(1));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
