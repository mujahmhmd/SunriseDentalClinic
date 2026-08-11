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
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * "Remember me" persistent login tokens. Unlike the plain HttpSession, a
 * valid token survives a Tomcat redeploy (which destroys all in-memory
 * sessions) since it's re-validated against the database on the next
 * request instead of living only in server memory.
 */
public final class RememberTokenUtil {

    public static final String COOKIE_NAME = "remember_token";

    private static final SecureRandom RANDOM = new SecureRandom();

    private RememberTokenUtil() {
    }

    /**
     * Creates and stores a fresh token for the given user.
     *
     * @return the raw token to put in the browser's cookie (the database
     *         only ever stores its hash)
     */
    public static String issue(int userId, int validDays) throws SQLException {
        String token = generateToken();
        Timestamp expiresAt = Timestamp.from(Instant.now().plusSeconds((long) validDays * 24 * 3600));

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "INSERT INTO remember_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)")) {
            ps.setInt(1, userId);
            ps.setString(2, hash(token));
            ps.setTimestamp(3, expiresAt);
            ps.executeUpdate();
        }

        return token;
    }

    /**
     * @return the login details (username, name, role) for an unexpired,
     *         still-active-account token, or null if the token is missing,
     *         expired, or the account has since been deactivated/deleted
     */
    public static Map<String, String> validate(String rawToken) throws SQLException {
        if (rawToken == null || rawToken.isEmpty()) {
            return null;
        }

        String sql = "SELECT u.username, u.name, u.role, u.status FROM remember_tokens t " +
                "JOIN users u ON u.id = t.user_id " +
                "WHERE t.token_hash = ? AND t.expires_at > NOW()";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hash(rawToken));
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next() || !"active".equals(rs.getString("status"))) {
                    return null;
                }
                Map<String, String> user = new LinkedHashMap<>();
                user.put("username", rs.getString("username"));
                user.put("name", rs.getString("name"));
                user.put("role", rs.getString("role"));
                return user;
            }
        }
    }

    /** Deletes a token (e.g. on logout) so a copied cookie can't be replayed afterward. */
    public static void revoke(String rawToken) throws SQLException {
        if (rawToken == null || rawToken.isEmpty()) {
            return;
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM remember_tokens WHERE token_hash = ?")) {
            ps.setString(1, hash(rawToken));
            ps.executeUpdate();
        }
    }

    private static String generateToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private static String hash(String token) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(token.getBytes(StandardCharsets.UTF_8));
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
