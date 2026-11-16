-- Lab 4 - Problem 1 : COMPANY database (DDL)
-- Amr Khalid Mohamed - 2304120 | Seif Walid - 2404028
-- Run: mysql -u root -p < problem1_DDL.sql

DROP DATABASE IF EXISTS company;
CREATE DATABASE company;
USE company;

-- DEPARTMENT is created first without its FK to EMPLOYEE (circular reference);
-- the FK on mgr_ssn is added with ALTER TABLE after EMPLOYEE exists.
CREATE TABLE department (
    Dnumber        INT          NOT NULL,
    Dname          VARCHAR(50)  NOT NULL UNIQUE,
    mgr_ssn        CHAR(9)      NULL,
    mgr_start_date DATE         NULL,
    CONSTRAINT pk_department PRIMARY KEY (Dnumber)
) ENGINE = InnoDB;

CREATE TABLE employee (
    ssn       CHAR(9)       NOT NULL,
    fname     VARCHAR(30)   NOT NULL,
    lname     VARCHAR(30)   NOT NULL,
    bdate     DATE,
    address   VARCHAR(100),
    gender    CHAR(1)       CHECK (gender IN ('M', 'F')),
    salary    DECIMAL(10,2) CHECK (salary >= 0),
    super_ssn CHAR(9)       NULL,
    Dno       INT           NOT NULL,
    CONSTRAINT pk_employee PRIMARY KEY (ssn),
    CONSTRAINT fk_employee_supervisor FOREIGN KEY (super_ssn) REFERENCES employee (ssn),
    CONSTRAINT fk_employee_department FOREIGN KEY (Dno) REFERENCES department (Dnumber)
) ENGINE = InnoDB;

ALTER TABLE department
    ADD CONSTRAINT fk_department_manager FOREIGN KEY (mgr_ssn) REFERENCES employee (ssn);

CREATE TABLE project (
    Pnumber   INT          NOT NULL,
    Pname     VARCHAR(50)  NOT NULL UNIQUE,
    Plocation VARCHAR(50),
    Dno       INT          NOT NULL,
    CONSTRAINT pk_project PRIMARY KEY (Pnumber),
    CONSTRAINT fk_project_department FOREIGN KEY (Dno) REFERENCES department (Dnumber)
) ENGINE = InnoDB;

CREATE TABLE works_on (
    essn  CHAR(9)      NOT NULL,
    Pno   INT          NOT NULL,
    hours DECIMAL(4,1) NOT NULL CHECK (hours >= 0),
    CONSTRAINT pk_works_on PRIMARY KEY (essn, Pno),               -- composite key
    CONSTRAINT fk_works_on_employee FOREIGN KEY (essn) REFERENCES employee (ssn),
    CONSTRAINT fk_works_on_project  FOREIGN KEY (Pno)  REFERENCES project (Pnumber)
) ENGINE = InnoDB;

CREATE TABLE dependent (
    essn           CHAR(9)     NOT NULL,
    dependent_name VARCHAR(30) NOT NULL,
    gender         CHAR(1)     CHECK (gender IN ('M', 'F')),
    bdate          DATE,
    relationship   VARCHAR(20),
    CONSTRAINT pk_dependent PRIMARY KEY (essn, dependent_name),   -- composite key (weak entity)
    CONSTRAINT fk_dependent_employee FOREIGN KEY (essn) REFERENCES employee (ssn)
) ENGINE = InnoDB;
