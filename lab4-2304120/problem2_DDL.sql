-- Lab 4 - Problem 2 : LIBRARY database (DDL)
-- Amr Khalid Mohamed - 2304120 | Seif Walid - 2404028
-- Run: mysql -u root -p < problem2_DDL.sql

DROP DATABASE IF EXISTS library;
CREATE DATABASE library CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE library;

CREATE TABLE author (
    author_id INT          NOT NULL AUTO_INCREMENT,
    name      VARCHAR(100) NOT NULL,
    country   VARCHAR(50),
    CONSTRAINT pk_author PRIMARY KEY (author_id)
) ENGINE = InnoDB;

CREATE TABLE publisher (
    publisher_id INT          NOT NULL AUTO_INCREMENT,
    name         VARCHAR(100) NOT NULL UNIQUE,
    country      VARCHAR(50),
    CONSTRAINT pk_publisher PRIMARY KEY (publisher_id)
) ENGINE = InnoDB;

CREATE TABLE category (
    category_id INT         NOT NULL AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT pk_category PRIMARY KEY (category_id)
) ENGINE = InnoDB;

CREATE TABLE book (
    book_id      INT           NOT NULL AUTO_INCREMENT,
    title        VARCHAR(200)  NOT NULL,
    price        DECIMAL(8,2)  NOT NULL CHECK (price >= 0),
    publish_year SMALLINT,
    author_id    INT           NOT NULL,
    publisher_id INT           NOT NULL,
    category_id  INT           NOT NULL,
    CONSTRAINT pk_book PRIMARY KEY (book_id),
    -- deleting an author deletes all of his/her books
    CONSTRAINT fk_book_author    FOREIGN KEY (author_id)    REFERENCES author (author_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id) REFERENCES publisher (publisher_id),
    CONSTRAINT fk_book_category  FOREIGN KEY (category_id)  REFERENCES category (category_id)
) ENGINE = InnoDB;

CREATE TABLE member (
    member_id INT          NOT NULL AUTO_INCREMENT,
    name      VARCHAR(100) NOT NULL,
    email     VARCHAR(255) NOT NULL UNIQUE,
    join_date DATE         NOT NULL,
    CONSTRAINT pk_member PRIMARY KEY (member_id)
) ENGINE = InnoDB;

CREATE TABLE loan (
    loan_id     INT  NOT NULL AUTO_INCREMENT,
    book_id     INT  NOT NULL,
    member_id   INT  NOT NULL,
    loan_date   DATE NOT NULL,
    return_date DATE NULL,                 -- NULL while the book is still borrowed
    CONSTRAINT pk_loan PRIMARY KEY (loan_id),
    -- deleting a book deletes its loans
    CONSTRAINT fk_loan_book   FOREIGN KEY (book_id)   REFERENCES book (book_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_loan_member FOREIGN KEY (member_id) REFERENCES member (member_id),
    CONSTRAINT chk_loan_dates CHECK (return_date IS NULL OR return_date >= loan_date)
) ENGINE = InnoDB;
