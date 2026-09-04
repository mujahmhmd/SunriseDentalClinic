package com.icbt.SunriseDentalClinic.util;

import com.icbt.SunriseDentalClinic.testsupport.DisplayNameReporter;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

@DisplayName("ServiceValidator - Create/Edit Service form rules")
@ExtendWith(DisplayNameReporter.class)
public class ServiceValidatorTest {

    @Test
    @DisplayName("A valid name and price with no description returns no error")
    public void validNameAndPrice_noDescription_returnsNull() {
        assertNull(ServiceValidator.validate("Dental Consultation", "1500", null));
    }

    @Test
    @DisplayName("A valid name, price and description returns no error")
    public void validNameAndPrice_withDescription_returnsNull() {
        assertNull(ServiceValidator.validate("Dental Consultation", "1500", "Initial examination and diagnosis"));
    }

    @Test
    @DisplayName("A service name under 3 characters is rejected")
    public void nameTooShort_returnsError() {
        assertEquals("Service name must be at least 3 characters.",
                ServiceValidator.validate("X", "1500", null));
    }

    @Test
    @DisplayName("A blank price is rejected")
    public void priceBlank_returnsError() {
        assertEquals("Enter a price.", ServiceValidator.validate("Consultation", "", null));
    }

    @Test
    @DisplayName("A null price is rejected")
    public void priceNull_returnsError() {
        assertEquals("Enter a price.", ServiceValidator.validate("Consultation", null, null));
    }

    @Test
    @DisplayName("A price of zero is rejected")
    public void priceZero_returnsError() {
        assertEquals("Price must be greater than 0.", ServiceValidator.validate("Consultation", "0", null));
    }

    @Test
    @DisplayName("A negative price is rejected")
    public void priceNegative_returnsError() {
        assertEquals("Price must be greater than 0.", ServiceValidator.validate("Consultation", "-5", null));
    }

    @Test
    @DisplayName("A non-numeric price is rejected")
    public void priceNotANumber_returnsError() {
        assertEquals("Price must be a valid number.", ServiceValidator.validate("Consultation", "cheap", null));
    }

    @Test
    @DisplayName("A description over 255 characters is rejected")
    public void descriptionOver255Characters_returnsError() {
        String longDescription = "a".repeat(256);
        assertEquals("Description must be under 255 characters.",
                ServiceValidator.validate("Consultation", "1500", longDescription));
    }

    @Test
    @DisplayName("A description of exactly 255 characters is accepted (the boundary case)")
    public void descriptionExactly255Characters_isAccepted() {
        String description = "a".repeat(255);
        assertNull(ServiceValidator.validate("Consultation", "1500", description));
    }
}
