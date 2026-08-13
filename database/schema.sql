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

-- One visiting-hours row per day a doctor is available. A doctor can have
-- 0-7 rows (0 = no schedule set yet); one time range per day is enough for
-- a single-shift clinic, which covers the "10 AM to 1 PM"-style case asked for.
CREATE TABLE IF NOT EXISTS doctor_schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    UNIQUE KEY doctor_day (doctor_id, day_of_week),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
);

-- Patients don't log in either. NIC is nullable since children (a real case
-- here, given Pediatric Dentistry) don't have one issued in Sri Lanka until
-- around 15-16, so date_of_birth (not NIC) is the required identity field.
-- No status column — unlike Staff/Doctor, there's no login or booking
-- visibility for a patient's own "active" toggle to control; appointment
-- status will live on the future appointments table instead.
CREATE TABLE IF NOT EXISTS patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    nic VARCHAR(20) NULL,
    gender ENUM('Male', 'Female', 'Other') NULL,
    address VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Books an existing patient in with an existing doctor at a date/time.
-- Treatment isn't chosen here — the doctor decides what was actually done
-- during the visit, so services get attached separately once an appointment
-- is marked Completed (a later "appointment_services" join table), not on
-- this row. 'Processing Payment' is reserved for the future
-- complete-appointment payment step; nothing sets it yet.
--
-- No UNIQUE constraint on (doctor_id, date, time): a Cancelled appointment
-- must free up its slot for rebooking, so the double-booking check is done
-- in application code instead (excluding Cancelled rows) rather than at the
-- DB level.
--
-- There's no separate appointment-number column — the patient-facing
-- "SDC000001" reference shown on the receipt is just the id, zero-padded
-- and prefixed at display time (see AppointmentValidator.formatAppointmentNumber),
-- since the id already is a unique, ever-increasing identifier.
CREATE TABLE IF NOT EXISTS appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    reason_for_visit VARCHAR(255) NULL,
    notes VARCHAR(500) NULL,
    status ENUM('Scheduled', 'Processing Payment', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Scheduled',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
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

-- Treatment types offered by the clinic. Not tied to an appointment at
-- booking time (the actual treatment isn't known until the doctor sees the
-- patient) — appointments will instead attach one or more services once
-- marked complete, so this is just the priced catalog they're chosen from.
CREATE TABLE IF NOT EXISTS services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    description VARCHAR(255) NULL,
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Standard catalog, kept short rather than exhaustive. Prices are rough
-- placeholder LKR figures, not verified market rates — edit each one to
-- your clinic's actual pricing from the Services page.
INSERT IGNORE INTO services (name, price, description) VALUES
    ('Dental Consultation', 1500.00, 'Initial examination and diagnosis'),
    ('Scaling & Polishing', 4500.00, 'Routine cleaning to remove plaque, tartar and stains'),
    ('Tooth Filling', 5000.00, 'Restoration of a decayed or damaged tooth'),
    ('Tooth Extraction', 4000.00, 'Removal of a damaged or problematic tooth'),
    ('Root Canal Treatment', 15000.00, 'Treatment to save an infected or badly decayed tooth'),
    ('Teeth Whitening', 12000.00, 'Cosmetic whitening of stained or discolored teeth'),
    ('Dental Crown', 20000.00, 'Cap placed over a damaged or weakened tooth'),
    ('Dental Bridge', 35000.00, 'Fixed replacement for one or more missing teeth'),
    ('Dental Implant', 120000.00, 'Permanent replacement for a missing tooth root'),
    ('Braces / Orthodontic Treatment', 150000.00, 'Teeth alignment and bite correction'),
    ('Dentures (Full/Partial)', 45000.00, 'Removable replacement for missing teeth'),
    ('Dental X-Ray', 1000.00, 'Diagnostic imaging of teeth and jaw');

-- Seed accounts (passwords are bcrypt-hashed, never stored in plain text).
-- IGNORE makes this safe to re-run: rows are skipped (not duplicated or
-- errored on) if a username already exists from a previous run.
-- admin  / admin123
INSERT IGNORE INTO users (username, password, name, nic, role, status) VALUES
    ('admin',  '$2a$10$9etuIN4Vp13SdV./vezS8uPxLo1kIuxZGFazW/c1wNviXseoYkVLm', 'Clinic Admin', '200007703960', 'admin', 'active');
