-- Optional: run this after schema.sql to populate the Staffs page with test data.
-- All 15 accounts share the same password so you don't need to track 15 different ones.
-- Password for every account below: Staff@123

USE sunrisedentalclinic;

INSERT IGNORE INTO users (username, password, name, nic, address, phone, email, role, status) VALUES
    ('jane.perera',            '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Jane Perera',            '200012345671', 'Colombo',       '071 234 5671', 'jane.perera@sunrisedental.lk', 'staff', 'active'),
    ('kasun.silva',            '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Kasun Silva',            '199512345672', 'Kandy',         '071 234 5672', 'kasun.silva@sunrisedental.lk', 'staff', 'active'),
    ('nimali.fernando',        '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Nimali Fernando',        '199812345673', 'Galle',         '072 234 5673', 'nimali.fernando@sunrisedental.lk', 'staff', 'active'),
    ('ruwan.jayasuriya',       '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Ruwan Jayasuriya',       '199312345674', 'Jaffna',        '072 234 5674', 'ruwan.jayasuriya@sunrisedental.lk', 'staff', 'inactive'),
    ('dilani.wickramasinghe',  '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Dilani Wickramasinghe',  '200112345675', 'Trincomalee',   '077 234 5675', 'dilani.wickramasinghe@sunrisedental.lk', 'staff', 'active'),
    ('chamara.rathnayake',     '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Chamara Rathnayake',     '199712345676', 'Matara',        '077 234 5676', 'chamara.rathnayake@sunrisedental.lk', 'staff', 'active'),
    ('sanduni.gunawardena',    '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Sanduni Gunawardena',    '199912345677', 'Negombo',       '070 234 5677', 'sanduni.gunawardena@sunrisedental.lk', 'staff', 'active'),
    ('tharindu.bandara',       '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Tharindu Bandara',       '199612345678', 'Anuradhapura',  '070 234 5678', 'tharindu.bandara@sunrisedental.lk', 'staff', 'inactive'),
    ('ishara.dias',            '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Ishara Dias',            '200212345679', 'Batticaloa',    '075 234 5679', 'ishara.dias@sunrisedental.lk', 'staff', 'active'),
    ('malith.senanayake',      '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Malith Senanayake',      '199412345680', 'Kurunegala',    '075 234 5680', 'malith.senanayake@sunrisedental.lk', 'staff', 'active'),
    ('hansika.rajapaksha',     '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Hansika Rajapaksha',     '200012345681', 'Ratnapura',     '076 234 5681', 'hansika.rajapaksha@sunrisedental.lk', 'staff', 'active'),
    ('lakshan.peiris',         '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Lakshan Peiris',         '199912345682', 'Badulla',       '076 234 5682', 'lakshan.peiris@sunrisedental.lk', 'staff', 'active'),
    ('anushka.kumari',         '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Anushka Kumari',         '199812345683', 'Nuwara Eliya',  '078 234 5683', 'anushka.kumari@sunrisedental.lk', 'staff', 'inactive'),
    ('nadeesha.abeysekara',    '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Nadeesha Abeysekara',    '200312345684', 'Gampaha',       '078 234 5684', 'nadeesha.abeysekara@sunrisedental.lk', 'staff', 'active'),
    ('supun.karunaratne',      '$2a$10$5iYsMcoM.yV9ojDcEVUJsuOBEuS0kXYDEpENl2JJROobIuwyoj4rC', 'Supun Karunaratne',      '199512345685', 'Kalutara',      '071 234 5685', 'supun.karunaratne@sunrisedental.lk', 'staff', 'active');

-- Backfills email for these accounts on a DB where they were already seeded
-- before the email column existed (INSERT IGNORE above would skip them in
-- that case). Generic to any staff row missing one, not just these 15, so
-- it also covers a staff account added by hand before email was mandatory.
UPDATE users SET email = CONCAT(username, '@sunrisedental.lk')
WHERE role = 'staff' AND (email IS NULL OR email = '');
