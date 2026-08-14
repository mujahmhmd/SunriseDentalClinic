package com.icbt.SunriseDentalClinic.util;

import com.icbt.SunriseDentalClinic.db.DBConnection;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;

/**
 * Forgot-password OTPs. Mirrors RememberTokenUtil's approach: only the
 * SHA-256 hash is ever stored, never the raw code. A MySQL event
 * (schema.sql) auto-deletes expired rows every minute; issue() also clears
 * this user's own expired/used rows as a fallback in case that event
 * scheduler isn't running.
 */
public final class OtpUtil {

    public static final int OTP_VALID_MINUTES = 3;

    private static final SecureRandom RANDOM = new SecureRandom();

    private OtpUtil() {
    }

    /** Issues a fresh 6-digit code for the user, replacing any of their still-outstanding codes. */
    public static String issue(int userId) throws SQLException {
        String otp = String.format("%06d", RANDOM.nextInt(1_000_000));
        Timestamp expiresAt = Timestamp.from(Instant.now().plusSeconds(OTP_VALID_MINUTES * 60L));

        try (Connection conn = DBConnection.getConnection()) {
            // One live code per account at a time — clears anything
            // outstanding (expired, used, or not) before issuing a fresh one.
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM password_reset_otps WHERE user_id = ?")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO password_reset_otps (user_id, otp_hash, expires_at) VALUES (?, ?, ?)")) {
                ps.setInt(1, userId);
                ps.setString(2, hash(otp));
                ps.setTimestamp(3, expiresAt);
                ps.executeUpdate();
            }
        }
        return otp;
    }

    /** @return true if this is the current, unexpired, unused code for that user */
    public static boolean verify(int userId, String otp) throws SQLException {
        if (otp == null || otp.trim().isEmpty()) return false;
        String sql = "SELECT 1 FROM password_reset_otps WHERE user_id = ? AND otp_hash = ? " +
                "AND used = 0 AND expires_at > NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, hash(otp.trim()));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Marks this user's current code used so it can't be replayed after the password's been reset. */
    public static void markUsed(int userId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE password_reset_otps SET used = 1 WHERE user_id = ?")) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    private static String hash(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                hex.append(String.format("%02x", b & 0xff));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 unavailable", e);
        }
    }
}
