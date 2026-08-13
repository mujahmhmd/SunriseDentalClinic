package com.icbt.SunriseDentalClinic.util;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.regex.Pattern;

/**
 * Server-side mirror of assets/js/patient-form-validation.js. The JS gives
 * instant inline feedback; this is the actual source of truth since a
 * request can always bypass the browser's JS.
 */
public final class PatientValidator {

    // Sri Lankan NIC: old format is 9 digits + V/X (e.g. 912345678V),
    // new format is 12 digits with no letter (e.g. 200012345678). Optional
    // here — children don't have one issued yet.
    private static final Pattern NIC_PATTERN = Pattern.compile("^(\\d{9}[VXvx]|\\d{12})$");

    // Sri Lankan local number: 10 digits starting with 0 (e.g. 0712345678).
    private static final Pattern PHONE_PATTERN = Pattern.compile("^0\\d{9}$");

    private static final int MAX_AGE_YEARS = 120;

    private PatientValidator() {
    }

    /**
     * @param dateOfBirth "yyyy-MM-dd" (the format an &lt;input type="date"&gt; submits)
     * @return the first validation error found, or null if everything's valid
     */
    public static String validate(String name, String dateOfBirth, String phone, String nic, String gender) {

        if (name == null || name.trim().length() < 3) {
            return "Full name must be at least 3 characters.";
        }

        if (dateOfBirth == null || dateOfBirth.trim().isEmpty()) {
            return "Date of birth is required.";
        }
        LocalDate dob;
        try {
            dob = LocalDate.parse(dateOfBirth.trim());
        } catch (DateTimeParseException e) {
            return "Enter a valid date of birth.";
        }
        LocalDate today = LocalDate.now();
        if (dob.isAfter(today)) {
            return "Date of birth can't be in the future.";
        }
        if (dob.isBefore(today.minusYears(MAX_AGE_YEARS))) {
            return "Enter a valid date of birth.";
        }

        if (phone == null || !PHONE_PATTERN.matcher(StaffValidator.normalizePhone(phone)).matches()) {
            return "Enter a valid 10-digit number starting with 0 (e.g. 0712345678).";
        }

        // NIC is optional (children don't have one), but if given, it must be valid.
        if (nic != null && !nic.trim().isEmpty() && !NIC_PATTERN.matcher(nic.trim()).matches()) {
            return "Enter a valid NIC: 9 digits + V/X (e.g. 912345678V) or 12 digits (e.g. 200012345678).";
        }

        if (gender != null && !gender.trim().isEmpty()
                && !gender.equals("Male") && !gender.equals("Female") && !gender.equals("Other")) {
            return "Select a valid gender.";
        }

        return null;
    }
}
