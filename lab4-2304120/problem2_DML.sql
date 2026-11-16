-- Lab 4 - Problem 2 : LIBRARY database (seed data)
-- Amr Khalid Mohamed - 2304120 | Seif Walid - 2404028
-- Run after problem2_DDL.sql:  mysql -u root -p < problem2_DML.sql
--
-- The data contains everything the pages need:
--   * two authors from the same country ......... Naguib Mahfouz & Ahmed Khaled Tawfik (Egypt)
--   * an author with no books .................... Paulo Coelho
--   * an author who wrote at least 2 books ....... Mahfouz (3), Orwell (3), Rowling (3), Tawfik (2)
--   * an author and a publisher, same country .... Mahfouz & Dar El Shorouk (Egypt)
--   * a book priced between 15 and 20 ............ Palace Walk 18.50, Utopia 15.00, 1984 16.75 ...
--   * a book that was never borrowed ............. The Casual Vacancy, Down and Out in Paris and London
--   * a member with no loans ..................... Khaled Mostafa
--   * a loan that is not returned yet ............ loans 3, 7, 10, 13, 14 (return_date NULL)

USE library;

INSERT INTO author (author_id, name, country) VALUES
    (1, 'Naguib Mahfouz',      'Egypt'),
    (2, 'Ahmed Khaled Tawfik', 'Egypt'),
    (3, 'George Orwell',       'UK'),
    (4, 'J. K. Rowling',       'UK'),
    (5, 'Paulo Coelho',        'Brazil');      -- no books

INSERT INTO publisher (publisher_id, name, country) VALUES
    (1, 'Dar El Shorouk', 'Egypt'),
    (2, 'Penguin Books',  'UK'),
    (3, 'Bloomsbury',     'UK'),
    (4, 'HarperCollins',  'USA');

INSERT INTO category (category_id, name) VALUES
    (1, 'Novel'),
    (2, 'Fantasy'),
    (3, 'Horror'),
    (4, 'Dystopian');

INSERT INTO book (book_id, title, price, publish_year, author_id, publisher_id, category_id) VALUES
    (1,  'Palace Walk',                              18.50, 1956, 1, 1, 1),
    (2,  'Children of Gebelawi',                     22.00, 1959, 1, 1, 1),
    (3,  'The Thief and the Dogs',                   12.00, 1961, 1, 2, 1),
    (4,  'Utopia',                                   15.00, 2008, 2, 1, 4),
    (5,  'Paranormal: The Legend of the Tower',       9.50, 1993, 2, 1, 3),
    (6,  'Nineteen Eighty-Four',                     16.75, 1949, 3, 2, 4),
    (7,  'Animal Farm',                              11.00, 1945, 3, 2, 1),
    (8,  'Harry Potter and the Philosopher''s Stone', 25.00, 1997, 4, 3, 2),
    (9,  'Harry Potter and the Chamber of Secrets',  24.00, 1998, 4, 3, 2),
    (10, 'The Casual Vacancy',                       19.99, 2012, 4, 4, 1),   -- never borrowed
    (11, 'Down and Out in Paris and London',         13.50, 1933, 3, 2, 1);   -- never borrowed

INSERT INTO member (member_id, name, email, join_date) VALUES
    (1, 'Ahmed Samir',    'ahmed.samir@example.com',    '2026-01-10'),
    (2, 'Mariam Hossam',  'mariam.hossam@example.com',  '2026-02-03'),
    (3, 'Youssef Adel',   'youssef.adel@example.com',   '2026-03-15'),
    (4, 'Nada Ibrahim',   'nada.ibrahim@example.com',   '2026-04-22'),
    (5, 'Khaled Mostafa', 'khaled.mostafa@example.com', '2026-06-01'),   -- no loans
    (6, 'Salma Fawzy',    'salma.fawzy@example.com',    '2026-07-19');

INSERT INTO loan (loan_id, book_id, member_id, loan_date, return_date) VALUES
    (1,  8, 1, '2026-09-01', '2026-09-15'),
    (2,  8, 2, '2026-09-20', '2026-10-02'),
    (3,  8, 3, '2026-10-10', NULL),
    (4,  6, 1, '2026-09-05', '2026-09-19'),
    (5,  6, 4, '2026-10-01', '2026-10-12'),
    (6,  1, 2, '2026-09-10', '2026-09-25'),
    (7,  1, 1, '2026-10-20', NULL),
    (8,  4, 3, '2026-09-12', '2026-09-30'),
    (9,  9, 1, '2026-10-05', '2026-10-19'),
    (10, 2, 4, '2026-10-15', NULL),
    (11, 3, 6, '2026-09-18', '2026-10-01'),
    (12, 5, 2, '2026-10-25', '2026-11-05'),
    (13, 7, 6, '2026-11-01', NULL),
    (14, 6, 3, '2026-11-03', NULL);
