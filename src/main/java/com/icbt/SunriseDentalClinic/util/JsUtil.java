package com.icbt.SunriseDentalClinic.util;

/**
 * Escapes a value for safe use inside a single-quoted JavaScript string
 * literal embedded in a JSP (e.g. showToast('&lt;%= JsUtil.escape(msg) %&gt;', ...)).
 * Without this, a message containing an apostrophe - "You don't have
 * access...", "Selected patient couldn't be found..." - terminates the
 * string early and breaks the whole inline &lt;script&gt; block, silently
 * skipping everything after it (including any history.replaceState cleanup).
 */
public final class JsUtil {

    private JsUtil() {
    }

    public static String escape(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
                .replace("\\", "\\\\")
                .replace("'", "\\'")
                .replace("\r", "")
                .replace("\n", "\\n");
    }
}
