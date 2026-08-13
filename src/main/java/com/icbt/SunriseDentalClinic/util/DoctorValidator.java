package com.icbt.SunriseDentalClinic.util;

import java.util.Map;
import java.util.regex.Pattern;

/**
 * Server-side mirror of assets/js/doctor-form-validation.js. The JS gives
 * instant inline feedback; this is the actual source of truth since a
 * request can always bypass the browser's JS.
 */
public final class DoctorValidator {

    /** Shared with the servlets and JSPs so the day list only lives in one place. */
    public static final String[] DAYS = {
            "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    };

    /**
     * Whole-hour visiting-time options, clinic hours only (9 AM-5 PM).
     * {form value "HH:mm", display label}. Kept in this one place since both
     * create-doctor.jsp and edit-doctor.jsp render the same tag options.
     */
    public static final String[][] HOURS = {
            {"09:00", "9 AM"}, {"10:00", "10 AM"}, {"11:00", "11 AM"}, {"12:00", "12 PM"},
            {"13:00", "1 PM"}, {"14:00", "2 PM"}, {"15:00", "3 PM"}, {"16:00", "4 PM"}, {"17:00", "5 PM"}
    };

    // Sri Lankan NIC: old format is 9 digits + V/X (e.g. 912345678V),
    // new format is 12 digits with no letter (e.g. 200012345678).
    private static final Pattern NIC_PATTERN = Pattern.compile("^(\\d{9}[VXvx]|\\d{12})$");

    // Sri Lankan local number: 10 digits starting with 0 (e.g. 0712345678).
    private static final Pattern PHONE_PATTERN = Pattern.compile("^0\\d{9}$");

    // SLMC doesn't publish one rigid public format the way NIC does, so this
    // is a lenient sanity check (letters/digits/hyphens, 3-15 chars) rather
    // than an authoritative registration-number validator.
    private static final Pattern SLMC_PATTERN = Pattern.compile("^[A-Za-z0-9-]{3,15}$");

    private DoctorValidator() {
    }

    /** @return the first validation error found, or null if everything's valid */
    public static String validate(String name, String nic, String phone, String slmcRegNo,
                                   String qualifications, String experienceYears, String consultationFee,
                                   String[] specializationIds) {

        if (name == null || name.trim().length() < 3) {
            return "Full name must be at least 3 characters.";
        }
        if (nic == null || !NIC_PATTERN.matcher(nic.trim()).matches()) {
            return "Enter a valid NIC: 9 digits + V/X (e.g. 912345678V) or 12 digits (e.g. 200012345678).";
        }
        if (phone == null || !PHONE_PATTERN.matcher(StaffValidator.normalizePhone(phone)).matches()) {
            return "Enter a valid 10-digit number starting with 0 (e.g. 0712345678).";
        }
        if (slmcRegNo == null || !SLMC_PATTERN.matcher(slmcRegNo.trim()).matches()) {
            return "Enter a valid SLMC registration number (letters, numbers, hyphens, 3-15 characters).";
        }
        if (qualifications == null || qualifications.trim().length() < 2) {
            return "Enter the doctor's qualifications (e.g. BDS).";
        }
        if (specializationIds == null || specializationIds.length == 0) {
            return "Select at least one specialization.";
        }

        if (experienceYears != null && !experienceYears.trim().isEmpty()) {
            try {
                int years = Integer.parseInt(experienceYears.trim());
                if (years < 0 || years > 60) {
                    return "Years of experience must be between 0 and 60.";
                }
            } catch (NumberFormatException e) {
                return "Years of experience must be a whole number.";
            }
        }

        if (consultationFee == null || consultationFee.trim().isEmpty()) {
            return "Enter a consultation fee.";
        }
        try {
            double fee = Double.parseDouble(consultationFee.trim());
            if (fee <= 0) {
                return "Consultation fee must be greater than 0.";
            }
        } catch (NumberFormatException e) {
            return "Consultation fee must be a valid number.";
        }

        return null;
    }

    /**
     * @param days       the visiting days that were toggled on (e.g. from
     *                   request.getParameterValues("days")); no days selected
     *                   is fine — a schedule isn't mandatory
     * @param startTimes day name -> "start_&lt;day&gt;" form value ("HH:mm")
     * @param endTimes   day name -> "end_&lt;day&gt;" form value ("HH:mm")
     * @return the first validation error found, or null if everything's valid
     */
    public static String validateSchedule(String[] days, Map<String, String> startTimes, Map<String, String> endTimes) {
        if (days == null) {
            return null;
        }
        for (String day : days) {
            String start = startTimes.get(day);
            String end = endTimes.get(day);
            if (start == null || start.isEmpty() || end == null || end.isEmpty()) {
                return "Set a visiting time range for " + day + ".";
            }
            // "HH:mm" strings compare correctly as plain strings since they're
            // fixed-width and zero-padded.
            if (start.compareTo(end) >= 0) {
                return "For " + day + ", the end time must be after the start time.";
            }
        }
        return null;
    }
}
