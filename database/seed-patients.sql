-- Optional: run this after schema.sql to populate the Patients page with
-- realistic test data — 6 adults (with NIC) and 7 children (no NIC, since
-- Sri Lanka doesn't issue one until ~15-16 — exactly the case date_of_birth
-- was added to handle instead of requiring NIC).
--
-- NOTE: unlike seed-staff.sql/seed-doctors.sql, this is NOT safe to re-run —
-- patients has no natural unique key (no username/slmc_reg_no equivalent),
-- so running this twice will insert 13 duplicate rows. Run it once.

USE sunrisedentalclinic;

-- Adults (6)
INSERT INTO patients (name, date_of_birth, phone, nic, gender, address) VALUES
    ('Kamal Perera',            '1985-04-12', '0711111111', '198510312345', 'Male',   'Colombo'),
    ('Sanduni Fernando',        '1990-07-22', '0772222222', '902034567V',   'Female', 'Kandy'),
    ('Nimal Rajapaksha',        '1978-11-05', '0764444444', '197830912345', 'Male',   'Negombo'),
    ('Priya Kandiah',           '1995-01-30', '0775555555', '950304567V',   'Female', 'Jaffna'),
    ('Roshan Gunasekara',       '1965-06-18', '0757777777', '651704567V',   'Male',   'Matara'),
    ('Vithya Sivakumar',        '1998-10-03', '0771313131', '982764567V',   'Other',  'Vavuniya');

-- Children (7) — nic left NULL, matching real Sri Lankan practice
INSERT INTO patients (name, date_of_birth, phone, nic, gender, address) VALUES
    ('Tharusha Silva',          '2015-03-10', '0713333333', NULL, 'Male',   'Galle'),
    ('Aisha Rizwan',            '2018-09-14', '0716666666', NULL, 'Female', 'Kalmunai'),
    ('Kavindu Bandara',         '2013-05-08', '0779999999', NULL, 'Male',   'Anuradhapura'),
    ('Nethmi Perera',           '2020-02-20', '0723456789', NULL, 'Female', 'Colombo'),
    ('Dinuka Fernando',         '2017-11-11', '0734567890', NULL, 'Male',   'Kandy'),
    ('Sithumi Rajapaksha',      '2012-06-25', '0745678901', NULL, 'Female', 'Negombo'),
    ('Yohan De Silva',          '2022-08-30', '0756789012', NULL, 'Male',   'Ratnapura');
