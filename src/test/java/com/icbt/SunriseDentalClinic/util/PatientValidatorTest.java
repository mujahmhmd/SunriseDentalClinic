package com.icbt.SunriseDentalClinic.util;

import com.icbt.SunriseDentalClinic.testsupport.DisplayNameReporter;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

@DisplayName("PatientValidator - Create/Edit Patient form rules")
@ExtendWith(DisplayNameReporter.class)
public class PatientValidatorTest {

    private static final String VALID_NAME = "Sanduni Fernando";
    private static final String VALID_DOB = "1995-06-15";
    private static final String VALID_PHONE = "0772222222";

    // --- formatPatientId / parsePatientCode -------------------------------

    @Test
    @DisplayName("formatPatientId(): the row id is zero-padded and prefixed with SDCP")
    public void formatPatientId_padsAndPrefixes() {
        assertEquals("SDCP000001", PatientValidator.formatPatientId(1));
        assertEquals("SDCP000042", PatientValidator.formatPatientId(42));
        assertEquals("SDCP123456", PatientValidator.formatPatientId(123456));
    }

    @Test
    @DisplayName("parsePatientCode(): an exact printed code decodes back to its row id")
    public void parsePatientCode_exactMatch_returnsId() {
        assertEquals(Integer.valueOf(42), PatientValidator.parsePatientCode("SDCP000042"));
    }

    @Test
    @DisplayName("parsePatientCode(): matching is case-insensitive")
    public void parsePatientCode_isCaseInsensitive() {
        assertEquals(Integer.valueOf(42), PatientValidator.parsePatientCode("sdcp000042"));
    }

    @Test
    @DisplayName("parsePatientCode(): missing leading zeros are tolerated")
    public void parsePatientCode_toleratesMissingLeadingZeros() {
        assertEquals(Integer.valueOf(42), PatientValidator.parsePatientCode("SDCP42"));
    }

    @Test
    @DisplayName("parsePatientCode(): plain text that isn't a code returns null")
    public void parsePatientCode_notACode_returnsNull() {
        assertNull(PatientValidator.parsePatientCode("Sanduni Fernando"));
    }

    @Test
    @DisplayName("parsePatientCode(): an all-zero id (SDCP000000) isn't a real id, returns null")
    public void parsePatientCode_zeroId_returnsNull() {
        // The pattern requires a non-zero leading digit - "SDCP000000" isn't a real id.
        assertNull(PatientValidator.parsePatientCode("SDCP000000"));
    }

    @Test
    @DisplayName("parsePatientCode(): a null query returns null")
    public void parsePatientCode_null_returnsNull() {
        assertNull(PatientValidator.parsePatientCode(null));
    }

    // --- validate ---------------------------------------------------------

    @Test
    @DisplayName("validate(): required fields valid, optional fields left blank, returns no error")
    public void allRequiredFieldsValid_optionalFieldsBlank_returnsNull() {
        assertNull(PatientValidator.validate(VALID_NAME, VALID_DOB, VALID_PHONE, "", "", ""));
    }

    @Test
    @DisplayName("validate(): every field including the optional ones valid returns no error")
    public void allFieldsIncludingOptionalValid_returnsNull() {
        assertNull(PatientValidator.validate(VALID_NAME, VALID_DOB, VALID_PHONE,
                "sanduni@example.com", "912345678V", "Female"));
    }

    @Test
    @DisplayName("validate(): a name under 3 characters is rejected")
    public void nameTooShort_returnsError() {
        assertEquals("Full name must be at least 3 characters.",
                PatientValidator.validate("Sa", VALID_DOB, VALID_PHONE, null, null, null));
    }

    @Test
    @DisplayName("validate(): a missing date of birth is rejected")
    public void dobMissing_returnsError() {
        assertEquals("Date of birth is required.",
                PatientValidator.validate(VALID_NAME, "", VALID_PHONE, null, null, null));
    }

    @Test
    @DisplayName("validate(): a date of birth in the wrong format is rejected")
    public void dobInvalidFormat_returnsError() {
        assertEquals("Enter a valid date of birth.",
                PatientValidator.validate(VALID_NAME, "15/06/1995", VALID_PHONE, null, null, null));
    }

    @Test
    @DisplayName("validate(): a date of birth in the future is rejected")
    public void dobInFuture_returnsError() {
        String tomorrow = LocalDate.now().plusDays(1).toString();
        assertEquals("Date of birth can't be in the future.",
                PatientValidator.validate(VALID_NAME, tomorrow, VALID_PHONE, null, null, null));
    }

    @Test
    @DisplayName("validate(): a date of birth more than 120 years ago is rejected")
    public void dobOver120YearsAgo_returnsError() {
        String tooOld = LocalDate.now().minusYears(121).toString();
        assertEquals("Enter a valid date of birth.",
                PatientValidator.validate(VALID_NAME, tooOld, VALID_PHONE, null, null, null));
    }

    @Test
    @DisplayName("validate(): a date of birth of today (a newborn) is accepted")
    public void dobToday_isAccepted() {
        String today = LocalDate.now().toString();
        assertNull(PatientValidator.validate(VALID_NAME, today, VALID_PHONE, null, null, null));
    }

    @Test
    @DisplayName("validate(): an invalid phone number is rejected")
    public void phoneInvalid_returnsError() {
        assertEquals("Enter a valid 10-digit number starting with 0 (e.g. 0712345678).",
                PatientValidator.validate(VALID_NAME, VALID_DOB, "123", null, null, null));
    }

    @Test
    @DisplayName("validate(): a blank email is fine, since it's optional")
    public void emailBlank_isFine_sinceOptional() {
        assertNull(PatientValidator.validate(VALID_NAME, VALID_DOB, VALID_PHONE, "", null, null));
    }

    @Test
    @DisplayName("validate(): an email that IS given but malformed is rejected")
    public void emailGiven_butInvalid_returnsError() {
        assertEquals("Enter a valid email address (e.g. mujahith.mohamed@gmail.com).",
                PatientValidator.validate(VALID_NAME, VALID_DOB, VALID_PHONE, "not-an-email", null, null));
    }

    @Test
    @DisplayName("validate(): a blank NIC is fine, since it's optional (e.g. for children)")
    public void nicBlank_isFine_sinceOptional() {
        assertNull(PatientValidator.validate(VALID_NAME, VALID_DOB, VALID_PHONE, null, "", null));
    }

    @Test
    @DisplayName("validate(): a NIC that IS given but invalid is rejected")
    public void nicGiven_butInvalid_returnsError() {
        assertEquals("Enter a valid NIC: 9 digits + V/X (e.g. 912345678V) or 12 digits (e.g. 200012345678).",
                PatientValidator.validate(VALID_NAME, VALID_DOB, VALID_PHONE, null, "not-a-nic", null));
    }

    @Test
    @DisplayName("validate(): a blank gender is fine, since it's optional")
    public void genderBlank_isFine_sinceOptional() {
        assertNull(PatientValidator.validate(VALID_NAME, VALID_DOB, VALID_PHONE, null, null, ""));
    }

    @Test
    @DisplayName("validate(): a gender value outside Male/Female/Other is rejected")
    public void genderInvalidValue_returnsError() {
        assertEquals("Select a valid gender.",
                PatientValidator.validate(VALID_NAME, VALID_DOB, VALID_PHONE, null, null, "Robot"));
    }

    @Test
    @DisplayName("validate(): each of Male, Female and Other is accepted")
    public void genderEachValidOption_isAccepted() {
        assertNull(PatientValidator.validate(VALID_NAME, VALID_DOB, VALID_PHONE, null, null, "Male"));
        assertNull(PatientValidator.validate(VALID_NAME, VALID_DOB, VALID_PHONE, null, null, "Female"));
        assertNull(PatientValidator.validate(VALID_NAME, VALID_DOB, VALID_PHONE, null, null, "Other"));
    }
}
