package com.icbt.SunriseDentalClinic.util;

import com.icbt.SunriseDentalClinic.testsupport.DisplayNameReporter;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

@DisplayName("AppointmentValidator - Book/Edit Appointment form rules")
@ExtendWith(DisplayNameReporter.class)
public class AppointmentValidatorTest {

    private static final String VALID_PATIENT_ID = "1";
    private static final String VALID_DOCTOR_ID = "2";
    private static final String VALID_TIME = "09:00";

    private static String tomorrow() {
        return LocalDate.now().plusDays(1).toString();
    }

    // --- formatAppointmentNumber / parseAppointmentNumber ------------------

    @Test
    @DisplayName("formatAppointmentNumber(): the row id is zero-padded and prefixed with SDC")
    public void formatAppointmentNumber_padsAndPrefixes() {
        assertEquals("SDC000001", AppointmentValidator.formatAppointmentNumber(1));
        assertEquals("SDC123456", AppointmentValidator.formatAppointmentNumber(123456));
    }

    @Test
    @DisplayName("parseAppointmentNumber(): an exact printed number decodes back to its row id")
    public void parseAppointmentNumber_exactMatch_returnsId() {
        assertEquals(Integer.valueOf(7), AppointmentValidator.parseAppointmentNumber("SDC000007"));
    }

    @Test
    @DisplayName("parseAppointmentNumber(): matching is case-insensitive and tolerates missing zero-padding")
    public void parseAppointmentNumber_isCaseInsensitiveAndTolerantOfPadding() {
        assertEquals(Integer.valueOf(7), AppointmentValidator.parseAppointmentNumber("sdc7"));
    }

    @Test
    @DisplayName("parseAppointmentNumber(): plain text that isn't a code returns null")
    public void parseAppointmentNumber_notACode_returnsNull() {
        assertNull(AppointmentValidator.parseAppointmentNumber("Sanduni Fernando"));
    }

    @Test
    @DisplayName("parseAppointmentNumber(): a null query returns null")
    public void parseAppointmentNumber_null_returnsNull() {
        assertNull(AppointmentValidator.parseAppointmentNumber(null));
    }

    // --- validate ---------------------------------------------------------

    @Test
    @DisplayName("validate(): every field valid returns no error")
    public void allFieldsValid_returnsNull() {
        assertNull(AppointmentValidator.validate(VALID_PATIENT_ID, VALID_DOCTOR_ID, tomorrow(),
                VALID_TIME, "Tooth pain", "Internal note"));
    }

    @Test
    @DisplayName("validate(): the optional reason and notes fields can be left blank")
    public void optionalFieldsBlank_isFine() {
        assertNull(AppointmentValidator.validate(VALID_PATIENT_ID, VALID_DOCTOR_ID, tomorrow(), VALID_TIME, null, null));
    }

    @Test
    @DisplayName("validate(): no patient selected is rejected")
    public void patientIdBlank_returnsError() {
        assertEquals("Select a patient from the search results.",
                AppointmentValidator.validate("", VALID_DOCTOR_ID, tomorrow(), VALID_TIME, null, null));
    }

    @Test
    @DisplayName("validate(): no doctor selected is rejected")
    public void doctorIdBlank_returnsError() {
        assertEquals("Select a doctor.",
                AppointmentValidator.validate(VALID_PATIENT_ID, "", tomorrow(), VALID_TIME, null, null));
    }

    @Test
    @DisplayName("validate(): no appointment date is rejected")
    public void dateBlank_returnsError() {
        assertEquals("Select an appointment date.",
                AppointmentValidator.validate(VALID_PATIENT_ID, VALID_DOCTOR_ID, "", VALID_TIME, null, null));
    }

    @Test
    @DisplayName("validate(): a date in the wrong format is rejected")
    public void dateInvalidFormat_returnsError() {
        assertEquals("Enter a valid appointment date.",
                AppointmentValidator.validate(VALID_PATIENT_ID, VALID_DOCTOR_ID, "28-08-2026", VALID_TIME, null, null));
    }

    @Test
    @DisplayName("validate(): a date in the past is rejected")
    public void dateInPast_returnsError() {
        String yesterday = LocalDate.now().minusDays(1).toString();
        assertEquals("Appointment date can't be in the past.",
                AppointmentValidator.validate(VALID_PATIENT_ID, VALID_DOCTOR_ID, yesterday, VALID_TIME, null, null));
    }

    @Test
    @DisplayName("validate(): today's date is accepted (a same-day booking)")
    public void dateToday_isAccepted() {
        String today = LocalDate.now().toString();
        assertNull(AppointmentValidator.validate(VALID_PATIENT_ID, VALID_DOCTOR_ID, today, VALID_TIME, null, null));
    }

    @Test
    @DisplayName("validate(): a time outside the bookable slots is rejected")
    public void timeOutsideBookableSlots_returnsError() {
        assertEquals("Select a valid appointment time.",
                AppointmentValidator.validate(VALID_PATIENT_ID, VALID_DOCTOR_ID, tomorrow(), "08:45", null, null));
    }

    @Test
    @DisplayName("validate(): every one of the 16 bookable time slots (9 AM-4:30 PM) is accepted")
    public void everyBookableSlot_isAccepted() {
        for (String[] slot : AppointmentValidator.TIME_SLOTS) {
            assertNull(AppointmentValidator.validate(VALID_PATIENT_ID, VALID_DOCTOR_ID, tomorrow(), slot[0], null, null),
                    "Slot " + slot[0] + " should be valid");
        }
    }

    @Test
    @DisplayName("validate(): a reason for visit over 255 characters is rejected")
    public void reasonOver255Characters_returnsError() {
        String longReason = "a".repeat(256);
        assertEquals("Reason for visit must be under 255 characters.",
                AppointmentValidator.validate(VALID_PATIENT_ID, VALID_DOCTOR_ID, tomorrow(), VALID_TIME, longReason, null));
    }

    @Test
    @DisplayName("validate(): notes over 500 characters is rejected")
    public void notesOver500Characters_returnsError() {
        String longNotes = "a".repeat(501);
        assertEquals("Notes must be under 500 characters.",
                AppointmentValidator.validate(VALID_PATIENT_ID, VALID_DOCTOR_ID, tomorrow(), VALID_TIME, null, longNotes));
    }
}
