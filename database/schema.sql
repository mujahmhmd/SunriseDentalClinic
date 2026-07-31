-- Run this in phpMyAdmin (or the mysql CLI) against your XAMPP MySQL instance.
-- Creates the sunrisedentalclinic DB (if missing) and the users table for login.

CREATE DATABASE IF NOT EXISTS sunrisedentalclinic;
USE sunrisedentalclinic;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(60) NOT NULL, -- bcrypt hash, always 60 chars
    name VARCHAR(100) NOT NULL,
    nic VARCHAR(20) NULL,
    address VARCHAR(255) NULL,
    phone VARCHAR(20) NULL,
    role ENUM('admin', 'staff') NOT NULL DEFAULT 'staff',
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Safe to re-run: adds the personal-detail columns to a users table that
-- already existed before they were introduced.
ALTER TABLE users ADD COLUMN IF NOT EXISTS nic VARCHAR(20) NULL AFTER name;
ALTER TABLE users ADD COLUMN IF NOT EXISTS address VARCHAR(255) NULL AFTER nic;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20) NULL AFTER address;

-- Seed accounts (passwords are bcrypt-hashed, never stored in plain text).
-- IGNORE makes this safe to re-run: rows are skipped (not duplicated or
-- errored on) if a username already exists from a previous run.
-- admin  / admin123
INSERT IGNORE INTO users (username, password, name, nic, role, status) VALUES
    ('admin',  '$2a$10$9etuIN4Vp13SdV./vezS8uPxLo1kIuxZGFazW/c1wNviXseoYkVLm', 'Clinic Admin', '200007703960', 'admin', 'active');
