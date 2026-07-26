-- Run this in phpMyAdmin (or the mysql CLI) against your XAMPP MySQL instance.
-- Creates the sunrisedentalclinic DB (if missing) and the users table for login.

CREATE DATABASE IF NOT EXISTS sunrisedentalclinic;
USE sunrisedentalclinic;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(60) NOT NULL, -- bcrypt hash, always 60 chars
    name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'staff') NOT NULL DEFAULT 'staff',
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Seed accounts (passwords are bcrypt-hashed, never stored in plain text).
-- admin  / admin123
-- staff1 / staff123
INSERT INTO users (username, password, name, role, status) VALUES
    ('admin',  '$2a$10$9etuIN4Vp13SdV./vezS8uPxLo1kIuxZGFazW/c1wNviXseoYkVLm', 'Clinic Admin', 'admin', 'active'),
    ('staff1', '$2a$10$/LExYZnYpXcaRuqoo01p7O0H3jgVMjljji9YhMChGkxqBrA/HwuSy', 'Front Desk Staff', 'staff', 'active');
