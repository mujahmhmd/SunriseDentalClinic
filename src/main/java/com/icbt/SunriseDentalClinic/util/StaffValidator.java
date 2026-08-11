package com.icbt.SunriseDentalClinic.util;

import java.util.regex.Pattern;

/**
 * Server-side mirror of assets/js/staff-form-validation.js. The JS gives
 * instant inline feedback; this is the actual source of truth since a
 * request can always bypass the browser's JS.
 */
public final class StaffValidator {

    // Sri Lankan NIC: old format is 9 digits + V/X (e.g. 912345678V),
    // new format is 12 digits with no letter (e.g. 200012345678).
    private static final Pattern NIC_PATTERN = Pattern.compile("^(\\d{9}[VXvx]|\\d{12})$");

    // Sri Lankan local number: 10 digits starting with 0 (e.g. 0712345678).
    private static final Pattern PHONE_PATTERN = Pattern.compile("^0\\d{9}$");

    // Lowercase letters/numbers; dot, underscore, hyphen allowed only between them; 3-16 chars total.
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-z0-9][a-z0-9._-]{1,14}[a-z0-9]$");

    // At least one lowercase, one uppercase, one digit, one special character, 6+ chars.
    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9]).{6,}$");

    private StaffValidator() {
    }

    /**
     * Strips spaces/hyphens (e.g. "071 234 5678" -> "0712345678") so what
     * ends up validated and stored is clean digits, regardless of how the
     * admin chose to type it.
     */
    public static String normalizePhone(String phone) {
        return phone == null ? null : phone.trim().replaceAll("[\\s-]", "");
    }

    /**
     * @param passwordRequired false on the edit form, where a blank password
     *                          means "keep the current one"
     * @return the first validation error found, or null if everything's valid
     */
    public static String validate(String name, String nic, String phone, String username,
                                   String password, boolean passwordRequired) {

        if (name == null || name.trim().length() < 3) {
            return "Full name must be at least 3 characters.";
        }
        if (nic == null || !NIC_PATTERN.matcher(nic.trim()).matches()) {
            return "Enter a valid NIC: 9 digits + V/X (e.g. 912345678V) or 12 digits (e.g. 200012345678).";
        }
        if (phone == null || !PHONE_PATTERN.matcher(normalizePhone(phone)).matches()) {
            return "Enter a valid 10-digit number starting with 0 (e.g. 0712345678).";
        }
        if (username == null || !USERNAME_PATTERN.matcher(username.trim()).matches()) {
            return "Username must be 3-16 characters: lowercase letters, numbers, dots, underscores or hyphens only (e.g. jane.perera).";
        }

        boolean passwordBlank = password == null || password.isEmpty();
        if (passwordBlank) {
            if (passwordRequired) {
                return "Password is required.";
            }
        } else if (!PASSWORD_PATTERN.matcher(password).matches()) {
            return "Password needs at least 6 characters, with an uppercase letter, a lowercase letter, a number and a special character.";
        }

        return null;
    }
}
