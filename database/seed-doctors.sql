-- Optional: run this after schema.sql to populate the Doctors page with
-- realistic test data - 16 doctors, every field filled (no NULLs left),
-- each with 1-2 specializations and a real weekly visiting schedule.
-- Safe to re-run: all inserts use IGNORE / natural keys (slmc_reg_no).

USE sunrisedentalclinic;

INSERT IGNORE INTO doctors (name, nic, phone, address, slmc_reg_no, qualifications, experience_years, consultation_fee, status) VALUES
    ('Chaminda Rajapaksha',      '198512345678', '0711234567', 'Colombo',       'SLMC12345', 'BDS (Colombo)',                                    12, 2000.00, 'active'),
    ('Priyanka Wickramasinghe',  '900123456V',   '0772345678', 'Kandy',         'SLMC12346', 'BDS (Peradeniya), MSc Orthodontics (UK)',          9,  3500.00, 'active'),
    ('Ruwan Fernando',           '197834567890', '0713456789', 'Galle',         'SLMC12347', 'BDS, MS Oral & Maxillofacial Surgery',             15, 4500.00, 'active'),
    ('Nilmini Perera',           '855678901V',   '0764567890', 'Negombo',       'SLMC12348', 'BDS (Colombo), Diploma in Periodontics',           7,  2500.00, 'active'),
    ('Suresh Kandiah',           '197245678901', '0775678901', 'Jaffna',        'SLMC12349', 'BDS, MSc Endodontics',                             11, 3000.00, 'active'),
    ('Ayesha Nazeer',            '926789012V',   '0716789012', 'Kalmunai',      'SLMC12350', 'BDS, Diploma in Pediatric Dentistry',              6,  2200.00, 'active'),
    ('Dinesh Gunasekara',        '197490123456', '0757890123', 'Matara',        'SLMC12351', 'BDS, MSc Prosthodontics',                          14, 3200.00, 'active'),
    ('Kamala Devi',              '918901234V',   '0718901234', 'Batticaloa',    'SLMC12352', 'BDS (Colombo), Certificate in Cosmetic Dentistry', 8,  2800.00, 'active'),
    ('Mohamed Rizwan',           '198812345098', '0779012345', 'Kattankudy',    'SLMC12353', 'BDS, MSc Implantology',                            10, 4000.00, 'active'),
    ('Shanika Jayasuriya',       '933456789V',   '0710123456', 'Kurunegala',    'SLMC12354', 'BDS, MOrth RCS',                                   9,  3300.00, 'active'),
    ('Anura Bandara',            '196723456789', '0761234567', 'Anuradhapura',  'SLMC12355', 'BDS, MSc Oral Pathology',                          18, 2600.00, 'active'),
    ('Fathima Rifka',            '947890123V',   '0722345678', 'Trincomalee',   'SLMC12356', 'BDS (Colombo), Diploma in Cosmetic Dentistry',     5,  2100.00, 'active'),
    ('Kasun Ratnayake',          '198956789012', '0713456780', 'Ratnapura',     'SLMC12357', 'BDS, MSc Periodontics & Implantology',             13, 3800.00, 'active'),
    ('Vithya Sivakumar',         '909012345V',   '0774567891', 'Vavuniya',      'SLMC12358', 'BDS, Diploma in Endodontics',                      7,  2400.00, 'active'),
    ('Nadeeka Silva',            '197634567123', '0765678902', 'Gampaha',       'SLMC12359', 'BDS, MSc Prosthodontics',                          16, 3600.00, 'active'),
    ('Roshan De Zoysa',          '196545678234', '0716789013', 'Kegalle',       'SLMC12360', 'BDS (Colombo)',                                    4,  1800.00, 'active');

-- Specializations: looked up by name/slmc_reg_no rather than hardcoded ids,
-- since auto-increment ids depend on insert order/history.
INSERT IGNORE INTO doctor_specializations (doctor_id, specialization_id)
SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12345' AND s.name = 'General Dentistry'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12346' AND s.name = 'Orthodontics'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12347' AND s.name = 'Oral & Maxillofacial Surgery'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12348' AND s.name = 'Periodontics'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12349' AND s.name = 'Endodontics'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12349' AND s.name = 'General Dentistry'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12350' AND s.name = 'Pediatric Dentistry'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12351' AND s.name = 'Prosthodontics'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12352' AND s.name = 'Cosmetic Dentistry'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12352' AND s.name = 'General Dentistry'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12353' AND s.name = 'Implantology'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12354' AND s.name = 'Orthodontics'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12354' AND s.name = 'Pediatric Dentistry'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12355' AND s.name = 'Oral Pathology'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12356' AND s.name = 'General Dentistry'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12356' AND s.name = 'Cosmetic Dentistry'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12357' AND s.name = 'Periodontics'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12357' AND s.name = 'Implantology'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12358' AND s.name = 'Endodontics'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12359' AND s.name = 'Prosthodontics'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12359' AND s.name = 'Cosmetic Dentistry'
UNION ALL SELECT d.id, s.id FROM doctors d, specializations s WHERE d.slmc_reg_no = 'SLMC12360' AND s.name = 'General Dentistry';

-- Visiting schedules: whole-hour ranges, same 9 AM-5 PM window the Create/Edit
-- Doctor form's tag picker offers, so this looks identical to admin-entered data.
INSERT IGNORE INTO doctor_schedules (doctor_id, day_of_week, start_time, end_time)
SELECT d.id, 'Monday',    '09:00:00', '13:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12345'
UNION ALL SELECT d.id, 'Wednesday',  '09:00:00', '13:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12345'
UNION ALL SELECT d.id, 'Friday',     '09:00:00', '13:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12345'

UNION ALL SELECT d.id, 'Tuesday',    '10:00:00', '14:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12346'
UNION ALL SELECT d.id, 'Thursday',   '10:00:00', '14:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12346'

UNION ALL SELECT d.id, 'Monday',     '13:00:00', '17:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12347'
UNION ALL SELECT d.id, 'Thursday',   '13:00:00', '17:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12347'

UNION ALL SELECT d.id, 'Wednesday',  '09:00:00', '12:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12348'
UNION ALL SELECT d.id, 'Saturday',   '09:00:00', '12:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12348'

UNION ALL SELECT d.id, 'Monday',     '09:00:00', '17:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12349'
UNION ALL SELECT d.id, 'Wednesday',  '09:00:00', '17:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12349'

UNION ALL SELECT d.id, 'Tuesday',    '09:00:00', '13:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12350'
UNION ALL SELECT d.id, 'Thursday',   '09:00:00', '13:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12350'
UNION ALL SELECT d.id, 'Saturday',   '09:00:00', '13:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12350'

UNION ALL SELECT d.id, 'Friday',     '10:00:00', '15:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12351'

UNION ALL SELECT d.id, 'Monday',     '14:00:00', '17:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12352'
UNION ALL SELECT d.id, 'Wednesday',  '14:00:00', '17:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12352'
UNION ALL SELECT d.id, 'Friday',     '14:00:00', '17:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12352'

UNION ALL SELECT d.id, 'Tuesday',    '09:00:00', '14:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12353'
UNION ALL SELECT d.id, 'Friday',     '09:00:00', '14:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12353'

UNION ALL SELECT d.id, 'Wednesday',  '10:00:00', '13:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12354'
UNION ALL SELECT d.id, 'Saturday',   '10:00:00', '13:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12354'

UNION ALL SELECT d.id, 'Monday',     '09:00:00', '12:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12355'

UNION ALL SELECT d.id, 'Tuesday',    '13:00:00', '17:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12356'
UNION ALL SELECT d.id, 'Thursday',   '13:00:00', '17:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12356'

UNION ALL SELECT d.id, 'Monday',     '10:00:00', '16:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12357'
UNION ALL SELECT d.id, 'Thursday',   '10:00:00', '16:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12357'

UNION ALL SELECT d.id, 'Wednesday',  '09:00:00', '13:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12358'
UNION ALL SELECT d.id, 'Friday',     '09:00:00', '13:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12358'

UNION ALL SELECT d.id, 'Sunday',     '09:00:00', '13:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12359'

UNION ALL SELECT d.id, 'Tuesday',    '09:00:00', '12:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12360'
UNION ALL SELECT d.id, 'Thursday',   '09:00:00', '12:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12360'
UNION ALL SELECT d.id, 'Saturday',   '09:00:00', '12:00:00' FROM doctors d WHERE d.slmc_reg_no = 'SLMC12360';
