package com.icbt.SunriseDentalClinic.util;

import com.icbt.SunriseDentalClinic.testsupport.DisplayNameReporter;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

@DisplayName("StaffValidator - Create/Edit Staff form rules")
@ExtendWith(DisplayNameReporter.class)
public class StaffValidatorTest {

    private static final String VALID_NAME = "Mujahith Mohamed";
    private static final String VALID_NIC = "200012345678";
    private static final String VALID_PHONE = "0712345678";
    private static final String VALID_EMAIL = "mujahith.mohamed@gmail.com";
    private static final String VALID_USERNAME = "mujahith.mohamed";
    private static final String VALID_PASSWORD = "Welcome@123";

    // --- normalizePhone -------------------------------------------------

    @Test
    @DisplayName("normalizePhone(): a null phone number stays null")
    public void normalizePhone_null_returnsNull() {
        assertNull(StaffValidator.normalizePhone(null));
    }

    @Test
    @DisplayName("normalizePhone(): spaces and hyphens are stripped out")
    public void normalizePhone_stripsSpacesAndHyphens() {
        assertEquals("0712345678", StaffValidator.normalizePhone("071 234 5678"));
        assertEquals("0712345678", StaffValidator.normalizePhone("071-234-5678"));
    }

    @Test
    @DisplayName("normalizePhone(): leading/trailing whitespace is trimmed")
    public void normalizePhone_trimsWhitespace() {
        assertEquals("0712345678", StaffValidator.normalizePhone("  0712345678  "));
    }

    // --- validate ---------------------------------------------------------

    @Test
    @DisplayName("validate(): every field valid returns no error")
    public void allFieldsValid_returnsNull() {
        assertNull(StaffValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_EMAIL,
                VALID_USERNAME, VALID_PASSWORD, true));
    }

    @Test
    @DisplayName("validate(): a name under 3 characters is rejected")
    public void nameTooShort_returnsError() {
        assertEquals("Full name must be at least 3 characters.",
                StaffValidator.validate("Jo", VALID_NIC, VALID_PHONE, VALID_EMAIL, VALID_USERNAME, VALID_PASSWORD, true));
    }

    @Test
    @DisplayName("validate(): the old 9-digit + V/X NIC format is accepted")
    public void nicOldFormat_isAccepted() {
        assertNull(StaffValidator.validate(VALID_NAME, "912345678V", VALID_PHONE, VALID_EMAIL, VALID_USERNAME, VALID_PASSWORD, true));
    }

    @Test
    @DisplayName("validate(): an invalid NIC is rejected")
    public void nicInvalid_returnsError() {
        assertEquals("Enter a valid NIC: 9 digits + V/X (e.g. 912345678V) or 12 digits (e.g. 200012345678).",
                StaffValidator.validate(VALID_NAME, "not-a-nic", VALID_PHONE, VALID_EMAIL, VALID_USERNAME, VALID_PASSWORD, true));
    }

    @Test
    @DisplayName("validate(): a phone number typed with spaces/hyphens is normalized and accepted")
    public void phoneWithSpacesAndHyphens_isNormalizedAndAccepted() {
        assertNull(StaffValidator.validate(VALID_NAME, VALID_NIC, "071 234 5678", VALID_EMAIL, VALID_USERNAME, VALID_PASSWORD, true));
    }

    @Test
    @DisplayName("validate(): a phone number that isn't 10 digits is rejected")
    public void phoneNotTenDigits_returnsError() {
        assertEquals("Enter a valid 10-digit number starting with 0 (e.g. 0712345678).",
                StaffValidator.validate(VALID_NAME, VALID_NIC, "12345", VALID_EMAIL, VALID_USERNAME, VALID_PASSWORD, true));
    }

    @Test
    @DisplayName("validate(): a malformed email address is rejected")
    public void emailInvalid_returnsError() {
        assertEquals("Enter a valid email address (e.g. mujahith.mohamed@gmail.com).",
                StaffValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, "not-an-email", VALID_USERNAME, VALID_PASSWORD, true));
    }

    @Test
    @DisplayName("validate(): a username with an uppercase letter is rejected")
    public void usernameWithUppercase_returnsError() {
        assertEquals("Username must be 3-16 characters: lowercase letters, numbers, dots, underscores or hyphens only (e.g. jane.perera).",
                StaffValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_EMAIL, "Mujahith", VALID_PASSWORD, true));
    }

    @Test
    @DisplayName("validate(): a username under 3 characters is rejected")
    public void usernameTooShort_returnsError() {
        assertEquals("Username must be 3-16 characters: lowercase letters, numbers, dots, underscores or hyphens only (e.g. jane.perera).",
                StaffValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_EMAIL, "ab", VALID_PASSWORD, true));
    }

    @Test
    @DisplayName("validate(): a blank password on the Create form (required) is rejected")
    public void blankPassword_whenRequired_returnsError() {
        assertEquals("Password is required.",
                StaffValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_EMAIL, VALID_USERNAME, "", true));
    }

    @Test
    @DisplayName("validate(): a blank password on the Edit form (optional) just keeps the current one")
    public void blankPassword_whenNotRequired_keepsCurrentPassword() {
        // Edit form: a blank password means "leave it unchanged", not an error.
        assertNull(StaffValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_EMAIL, VALID_USERNAME, "", false));
    }

    @Test
    @DisplayName("validate(): a password missing a special character is rejected")
    public void weakPassword_missingSpecialCharacter_returnsError() {
        assertEquals("Password needs at least 6 characters, with an uppercase letter, a lowercase letter, a number and a special character.",
                StaffValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_EMAIL, VALID_USERNAME, "Welcome123", true));
    }

    @Test
    @DisplayName("validate(): a password under 6 characters is rejected")
    public void weakPassword_tooShort_returnsError() {
        assertEquals("Password needs at least 6 characters, with an uppercase letter, a lowercase letter, a number and a special character.",
                StaffValidator.validate(VALID_NAME, VALID_NIC, VALID_PHONE, VALID_EMAIL, VALID_USERNAME, "W1@a", true));
    }

    @Test
    @DisplayName("validate(): when multiple fields are invalid, the first rule checked (name) wins")
    public void firstFailingRuleWins_nameCheckedBeforeNic() {
        // Both name and NIC are invalid here - name is checked first, so its
        // error is the one returned, not NIC's.
        assertEquals("Full name must be at least 3 characters.",
                StaffValidator.validate("Jo", "bad-nic", VALID_PHONE, VALID_EMAIL, VALID_USERNAME, VALID_PASSWORD, true));
    }
}
