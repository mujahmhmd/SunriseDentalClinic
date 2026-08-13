package com.icbt.SunriseDentalClinic.util;

/**
 * Server-side mirror of assets/js/service-form-validation.js. The JS gives
 * instant inline feedback; this is the actual source of truth since a
 * request can always bypass the browser's JS.
 */
public final class ServiceValidator {

    private ServiceValidator() {
    }

    /** @return the first validation error found, or null if everything's valid */
    public static String validate(String name, String price, String description) {

        if (name == null || name.trim().length() < 3) {
            return "Service name must be at least 3 characters.";
        }

        if (price == null || price.trim().isEmpty()) {
            return "Enter a price.";
        }
        try {
            double value = Double.parseDouble(price.trim());
            if (value <= 0) {
                return "Price must be greater than 0.";
            }
        } catch (NumberFormatException e) {
            return "Price must be a valid number.";
        }

        if (description != null && description.trim().length() > 255) {
            return "Description must be under 255 characters.";
        }

        return null;
    }
}
