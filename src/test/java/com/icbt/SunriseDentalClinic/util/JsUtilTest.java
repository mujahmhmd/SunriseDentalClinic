package com.icbt.SunriseDentalClinic.util;

import com.icbt.SunriseDentalClinic.testsupport.DisplayNameReporter;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * JsUtil.escape() exists to fix one specific bug: a message with an
 * apostrophe (e.g. "You don't have access...") breaking out of the
 * single-quoted JS string it's embedded in and silently killing the rest of
 * the inline &lt;script&gt; block. These tests pin that behavior down.
 */
@DisplayName("JsUtil.escape() - safely embedding a message inside a single-quoted JS string")
@ExtendWith(DisplayNameReporter.class)
public class JsUtilTest {

    @Test
    @DisplayName("A null value escapes to an empty string")
    public void nullValue_returnsEmptyString() {
        assertEquals("", JsUtil.escape(null));
    }

    @Test
    @DisplayName("A plain message with nothing special in it is left unchanged")
    public void plainMessage_isUnchanged() {
        assertEquals("Doctor added", JsUtil.escape("Doctor added"));
    }

    @Test
    @DisplayName("An apostrophe is escaped, so it can't end the JS string early")
    public void apostrophe_isEscaped() {
        assertEquals("You don\\'t have access to that page.",
                JsUtil.escape("You don't have access to that page."));
    }

    @Test
    @DisplayName("Backslashes are escaped first, before the apostrophe escaping runs")
    public void backslash_isEscapedBeforeOtherCharacters() {
        // If backslashes weren't escaped first, escaping the apostrophe would
        // itself introduce an unescaped backslash into the output.
        assertEquals("C:\\\\Temp \\'ok\\'", JsUtil.escape("C:\\Temp 'ok'"));
    }

    @Test
    @DisplayName("A lone carriage return is stripped out entirely")
    public void carriageReturn_isStripped() {
        assertEquals("line1line2", JsUtil.escape("line1\r\nline2".replace("\n", "")));
    }

    @Test
    @DisplayName("A newline becomes a literal \\n so the JS string stays on one line")
    public void newline_isEscapedAsLiteralBackslashN() {
        assertEquals("line1\\nline2", JsUtil.escape("line1\nline2"));
    }

    @Test
    @DisplayName("A Windows-style CRLF line ending collapses to just the escaped newline")
    public void windowsLineEnding_becomesEscapedNewlineOnly() {
        assertEquals("line1\\nline2", JsUtil.escape("line1\r\nline2"));
    }

    @Test
    @DisplayName("A non-String value (e.g. an Integer) is converted via toString() first")
    public void nonStringValue_isConvertedWithToString() {
        assertEquals("42", JsUtil.escape(42));
    }
}
