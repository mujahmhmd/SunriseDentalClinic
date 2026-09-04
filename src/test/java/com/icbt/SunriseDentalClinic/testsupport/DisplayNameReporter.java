package com.icbt.SunriseDentalClinic.testsupport;

import org.junit.jupiter.api.extension.ExtensionContext;
import org.junit.jupiter.api.extension.TestWatcher;

import java.util.Optional;

/**
 * Prints each test's @DisplayName to the console as it finishes. JUnit 5's
 * default console reporter (via Surefire) only shows one summary line per
 * test *class* during a plain "mvn test" run - it never prints the
 * @DisplayName text of individual tests, even though the metadata is there
 * (it does show up in an IDE's test tree, or via the JUnit Platform Console
 * Launcher's --details=tree). This is JUnit 5's own extension mechanism -
 * the direct successor to JUnit 4's "@Rule public TestWatcher" - for
 * projects that want that per-test line in plain terminal output too.
 *
 * Usage: {@code @ExtendWith(DisplayNameReporter.class)} on a test class.
 */
public class DisplayNameReporter implements TestWatcher {

    @Override
    public void testSuccessful(ExtensionContext context) {
        System.out.println("  [PASS] " + context.getDisplayName());
    }

    @Override
    public void testFailed(ExtensionContext context, Throwable cause) {
        System.out.println("  [FAIL] " + context.getDisplayName() + " -> " + cause.getMessage());
    }

    @Override
    public void testAborted(ExtensionContext context, Throwable cause) {
        System.out.println("  [SKIP] " + context.getDisplayName());
    }

    @Override
    public void testDisabled(ExtensionContext context, Optional<String> reason) {
        System.out.println("  [SKIP] " + context.getDisplayName());
    }
}
