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

-- "Remember me" persistent login tokens. A row here lets a browser skip
-- re-entering credentials (and survive a server redeploy, unlike the plain
-- HttpSession) until expires_at. Only the SHA-256 hash of the token is
-- stored, never the raw value the browser's cookie holds.
CREATE TABLE IF NOT EXISTS remember_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token_hash CHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Doctors are a separate concept from users: they never log into the portal,
-- so there's no username/password/role here — just clinic records staff
-- manage on their behalf.
CREATE TABLE IF NOT EXISTS doctors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    nic VARCHAR(20) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(255) NULL,
    slmc_reg_no VARCHAR(30) NOT NULL UNIQUE, -- Sri Lanka Medical Council registration number
    qualifications VARCHAR(255) NOT NULL,
    experience_years INT NULL,
    consultation_fee DECIMAL(10,2) NULL,
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Fixed list of specializations a doctor can be tagged with.
CREATE TABLE IF NOT EXISTS specializations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE
);

-- Many-to-many: a doctor can have more than one specialization.
CREATE TABLE IF NOT EXISTS doctor_specializations (
    doctor_id INT NOT NULL,
    specialization_id INT NOT NULL,
    PRIMARY KEY (doctor_id, specialization_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    FOREIGN KEY (specialization_id) REFERENCES specializations(id) ON DELETE CASCADE
);

INSERT IGNORE INTO specializations (name) VALUES
    ('General Dentistry'),
    ('Orthodontics'),
    ('Oral & Maxillofacial Surgery'),
    ('Periodontics'),
    ('Endodontics'),
    ('Prosthodontics'),
    ('Pediatric Dentistry'),
    ('Cosmetic Dentistry'),
    ('Oral Pathology'),
    ('Implantology');

-- Seed accounts (passwords are bcrypt-hashed, never stored in plain text).
-- IGNORE makes this safe to re-run: rows are skipped (not duplicated or
-- errored on) if a username already exists from a previous run.
-- admin  / admin123
INSERT IGNORE INTO users (username, password, name, nic, role, status) VALUES
    ('admin',  '$2a$10$9etuIN4Vp13SdV./vezS8uPxLo1kIuxZGFazW/c1wNviXseoYkVLm', 'Clinic Admin', '200007703960', 'admin', 'active');
