-- Lab 4 - Problem 1 : COMPANY database (DML - our rows)
-- Amr Khalid Mohamed - 2304120 | Seif Walid - 2404028
-- Run after problem1_DDL.sql:  mysql -u root -p < problem1_DML.sql
--
-- The rows are chosen so that every query of Q1.4-Q1.12 returns rows:
--   * an employee without a supervisor ......... Ahmed Hassan (super_ssn NULL)
--   * a department without employees ........... 6 Marketing
--   * a project nobody works on ................ 20 Newbenefits
--   * a department with more than 2 employees .. 5 Research (4 employees)
--   * an employee who works on two projects ..... Omar Samy, Mona Ali, Ahmed Hassan

USE company;

-- 1) departments first, managers are set at the end (mgr_ssn may be NULL)
INSERT INTO department (Dnumber, Dname, mgr_ssn, mgr_start_date) VALUES
    (1, 'Headquarters',   NULL, NULL),
    (4, 'Administration', NULL, NULL),
    (5, 'Research',       NULL, NULL),
    (6, 'Marketing',      NULL, NULL);

-- 2) employees: every supervisor is inserted before the people he/she supervises
INSERT INTO employee (ssn, fname, lname, bdate, address, gender, salary, super_ssn, Dno) VALUES
    ('111111111', 'Ahmed',   'Hassan', '1975-03-12', '12 Fouad St, Alexandria',      'M', 9000.00, NULL,        1),
    ('222222222', 'Mona',    'Ali',    '1982-07-25', '5 Sporting St, Alexandria',    'F', 5500.00, '111111111', 5),
    ('666666666', 'Nour',    'Tarek',  '1985-11-02', '20 Tahrir Sq, Cairo',          'F', 4800.00, '111111111', 4),
    ('333333333', 'Omar',    'Samy',   '1990-01-15', '8 Nasr City, Cairo',           'M', 4000.00, '222222222', 5),
    ('444444444', 'Sara',    'Adel',   '1993-05-30', '3 Smouha St, Alexandria',      'F', 3500.00, '222222222', 5),
    ('555555555', 'Youssef', 'Nabil',  '1996-09-09', '41 Miami St, Alexandria',      'M', 2800.00, '222222222', 5),
    ('777777777', 'Karim',   'Fathy',  '1998-02-20', '9 Gleem St, Alexandria',       'M', 2500.00, '666666666', 4);

-- 3) now the managers can be set
UPDATE department SET mgr_ssn = '111111111', mgr_start_date = '2015-06-01' WHERE Dnumber = 1;
UPDATE department SET mgr_ssn = '666666666', mgr_start_date = '2019-01-01' WHERE Dnumber = 4;
UPDATE department SET mgr_ssn = '222222222', mgr_start_date = '2018-05-22' WHERE Dnumber = 5;
-- department 6 (Marketing) has no manager and no employees yet

INSERT INTO project (Pnumber, Pname, Plocation, Dno) VALUES
    (1,  'ProductX',        'Alexandria', 5),
    (2,  'ProductY',        'Cairo',      5),
    (3,  'Reorganization',  'Alexandria', 1),
    (10, 'Computerization', 'Cairo',      4),
    (20, 'Newbenefits',     'Alexandria', 4);   -- nobody works on it

INSERT INTO works_on (essn, Pno, hours) VALUES
    ('333333333', 1,  20.0),
    ('333333333', 2,  10.0),
    ('444444444', 1,  15.0),
    ('555555555', 2,  12.0),
    ('222222222', 1,  10.0),
    ('222222222', 3,   5.0),
    ('111111111', 3,   8.0),
    ('666666666', 10, 25.0),
    ('777777777', 10, 10.0);

INSERT INTO dependent (essn, dependent_name, gender, bdate, relationship) VALUES
    ('333333333', 'Laila',  'F', '2018-04-05', 'Daughter'),
    ('222222222', 'Hany',   'M', '1980-10-14', 'Spouse'),
    ('111111111', 'Mariam', 'F', '1978-12-01', 'Spouse'),
    ('444444444', 'Ali',    'M', '2021-06-17', 'Son');
