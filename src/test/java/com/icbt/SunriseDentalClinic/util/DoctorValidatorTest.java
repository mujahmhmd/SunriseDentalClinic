package com.icbt.SunriseDentalClinic.util;

import com.icbt.SunriseDentalClinic.testsupport.DisplayNameReporter;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

@DisplayName("DoctorValidator - Create/Edit Doctor form rules")
@ExtendWith(DisplayNameReporter.class)
public class DoctorValidatorTest {

    private static final String VALID_NAME = "Anura Bandara";
    private static final String VALID_NIC = "197830912345";
    private static final String VALID_PHONE = "0771234567";
    private static final String VALID_SLMC = "SLMC-12345";
    private static final String VALID_QUALIFICATIONS = "BDS (Colombo)";
    private static final String[] VALID_SPECIALIZATIONS = {"1", "2"};

    // --- validate ---------------------------------------------------------

    @Test
    @DisplayName("validate(): every field valid returns no error")
    public void allFieldsValid_returnsNull() {
        assertNull(DoctorValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_SLMC,
                VALID_QUALIFICATIONS, "8", "2500", VALID_SPECIALIZATIONS));
    }

    @Test
    @DisplayName("validate(): years of experience left blank is fine, since it's optional")
    public void experienceYearsBlank_isFine_sinceOptional() {
        assertNull(DoctorValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_SLMC,
                VALID_QUALIFICATIONS, "", "2500", VALID_SPECIALIZATIONS));
    }

    @Test
    @DisplayName("validate(): a name under 3 characters is rejected")
    public void nameTooShort_returnsError() {
        assertEquals("Full name must be at least 3 characters.",
                DoctorValidator.validate("An", VALID_NIC, VALID_PHONE, VALID_SLMC, VALID_QUALIFICATIONS, "8", "2500", VALID_SPECIALIZATIONS));
    }

    @Test
    @DisplayName("validate(): an invalid NIC is rejected")
    public void nicInvalid_returnsError() {
        assertEquals("Enter a valid NIC: 9 digits + V/X (e.g. 912345678V) or 12 digits (e.g. 200012345678).",
                DoctorValidator.validate(VALID_NAME, "bad", VALID_PHONE, VALID_SLMC, VALID_QUALIFICATIONS, "8", "2500", VALID_SPECIALIZATIONS));
    }

    @Test
    @DisplayName("validate(): an invalid phone number is rejected")
    public void phoneInvalid_returnsError() {
        assertEquals("Enter a valid 10-digit number starting with 0 (e.g. 0712345678).",
                DoctorValidator.validate(VALID_NAME, VALID_NIC, "123", VALID_SLMC, VALID_QUALIFICATIONS, "8", "2500", VALID_SPECIALIZATIONS));
    }

    @Test
    @DisplayName("validate(): an invalid SLMC registration number is rejected")
    public void slmcInvalid_returnsError() {
        assertEquals("Enter a valid SLMC registration number (letters, numbers, hyphens, 3-15 characters).",
                DoctorValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, "a", VALID_QUALIFICATIONS, "8", "2500", VALID_SPECIALIZATIONS));
    }

    @Test
    @DisplayName("validate(): qualifications under 2 characters is rejected")
    public void qualificationsTooShort_returnsError() {
        assertEquals("Enter the doctor's qualifications (e.g. BDS).",
                DoctorValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_SLMC, "B", "8", "2500", VALID_SPECIALIZATIONS));
    }

    @Test
    @DisplayName("validate(): choosing zero specializations is rejected")
    public void noSpecializationSelected_returnsError() {
        assertEquals("Select at least one specialization.",
                DoctorValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_SLMC, VALID_QUALIFICATIONS, "8", "2500", new String[0]));
    }

    @Test
    @DisplayName("validate(): a null specializations array is rejected the same as empty")
    public void nullSpecializations_returnsError() {
        assertEquals("Select at least one specialization.",
                DoctorValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_SLMC, VALID_QUALIFICATIONS, "8", "2500", null));
    }

    @Test
    @DisplayName("validate(): negative years of experience is rejected")
    public void experienceYearsNegative_returnsError() {
        assertEquals("Years of experience must be between 0 and 60.",
                DoctorValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_SLMC, VALID_QUALIFICATIONS, "-1", "2500", VALID_SPECIALIZATIONS));
    }

    @Test
    @DisplayName("validate(): years of experience over 60 is rejected")
    public void experienceYearsOver60_returnsError() {
        assertEquals("Years of experience must be between 0 and 60.",
                DoctorValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_SLMC, VALID_QUALIFICATIONS, "61", "2500", VALID_SPECIALIZATIONS));
    }

    @Test
    @DisplayName("validate(): a non-numeric years-of-experience value is rejected")
    public void experienceYearsNotANumber_returnsError() {
        assertEquals("Years of experience must be a whole number.",
                DoctorValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_SLMC, VALID_QUALIFICATIONS, "eight", "2500", VALID_SPECIALIZATIONS));
    }

    @Test
    @DisplayName("validate(): a blank consultation fee is rejected")
    public void consultationFeeBlank_returnsError() {
        assertEquals("Enter a consultation fee.",
                DoctorValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_SLMC, VALID_QUALIFICATIONS, "8", "", VALID_SPECIALIZATIONS));
    }

    @Test
    @DisplayName("validate(): a zero consultation fee is rejected")
    public void consultationFeeZero_returnsError() {
        assertEquals("Consultation fee must be greater than 0.",
                DoctorValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_SLMC, VALID_QUALIFICATIONS, "8", "0", VALID_SPECIALIZATIONS));
    }

    @Test
    @DisplayName("validate(): a non-numeric consultation fee is rejected")
    public void consultationFeeNotANumber_returnsError() {
        assertEquals("Consultation fee must be a valid number.",
                DoctorValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_SLMC, VALID_QUALIFICATIONS, "8", "free", VALID_SPECIALIZATIONS));
    }

    // --- validateSchedule --------------------------------------------------

    @Test
    @DisplayName("validateSchedule(): no visiting days selected is fine, a schedule isn't mandatory")
    public void validateSchedule_noDaysSelected_returnsNull() {
        assertNull(DoctorValidator.validateSchedule(null, new HashMap<>(), new HashMap<>()));
    }

    @Test
    @DisplayName("validateSchedule(): a valid start/end time range returns no error")
    public void validateSchedule_validRange_returnsNull() {
        Map<String, String> start = new HashMap<>();
        Map<String, String> end = new HashMap<>();
        start.put("Monday", "09:00");
        end.put("Monday", "17:00");
        assertNull(DoctorValidator.validateSchedule(new String[]{"Monday"}, start, end));
    }

    @Test
    @DisplayName("validateSchedule(): a selected day missing its start time is rejected")
    public void validateSchedule_missingStartTime_returnsError() {
        Map<String, String> start = new HashMap<>();
        Map<String, String> end = new HashMap<>();
        end.put("Monday", "17:00");
        assertEquals("Set a visiting time range for Monday.",
                DoctorValidator.validateSchedule(new String[]{"Monday"}, start, end));
    }

    @Test
    @DisplayName("validateSchedule(): an end time before the start time is rejected")
    public void validateSchedule_endBeforeStart_returnsError() {
        Map<String, String> start = new HashMap<>();
        Map<String, String> end = new HashMap<>();
        start.put("Monday", "17:00");
        end.put("Monday", "09:00");
        assertEquals("For Monday, the end time must be after the start time.",
                DoctorValidator.validateSchedule(new String[]{"Monday"}, start, end));
    }

    @Test
    @DisplayName("validateSchedule(): an end time equal to the start time is rejected")
    public void validateSchedule_endEqualsStart_returnsError() {
        Map<String, String> start = new HashMap<>();
        Map<String, String> end = new HashMap<>();
        start.put("Monday", "09:00");
        end.put("Monday", "09:00");
        assertEquals("For Monday, the end time must be after the start time.",
                DoctorValidator.validateSchedule(new String[]{"Monday"}, start, end));
    }
}
