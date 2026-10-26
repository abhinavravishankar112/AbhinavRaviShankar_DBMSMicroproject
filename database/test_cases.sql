-- ===================================================================
--  library_db : test_cases.sql   (generated from src/test_cases.js)
--  Each test runs inside a transaction that is rolled back, so the
--  seeded data is unchanged afterwards. Run with --force so that the
--  script continues past the tests that are EXPECTED to be rejected:
--     mysql -u root -p -t --force library_db < test_cases.sql
-- ===================================================================
USE library_db;

-- TC1  [Foreign key constraint]
-- Action:   Insert a loan for member_id 99, which does not exist
-- Expected: Rejected by fk_loan_member
SELECT 'TC1' AS test, 'Rejected by fk_loan_member' AS expected;
START TRANSACTION;
INSERT INTO loan (copy_id, member_id, issued_on, due_on) VALUES (8, 99, '2026-10-26', '2026-11-09');
ROLLBACK;

-- TC2  [Foreign key constraint]
-- Action:   Insert a copy of ISBN '9789999999999', a book that does not exist
-- Expected: Rejected by fk_copy_book
SELECT 'TC2' AS test, 'Rejected by fk_copy_book' AS expected;
START TRANSACTION;
INSERT INTO copy (isbn, shelf_code) VALUES ('9789999999999', 'Z-999');
ROLLBACK;

-- TC3  [Foreign key (ON DELETE RESTRICT)]
-- Action:   Delete member 1, who has two outstanding loans
-- Expected: Rejected by fk_loan_member; nothing deleted
SELECT 'TC3' AS test, 'Rejected by fk_loan_member; nothing deleted' AS expected;
START TRANSACTION;
DELETE FROM member WHERE member_id = 1;
ROLLBACK;

-- TC4  [Related records]
-- Action:   Query all loans of the member riya@example.com
-- Expected: 2 loans: loan 1 (An Introduction to Database Systems) and loan 2 (Designing Data-Intensive Applications)
SELECT 'TC4' AS test, '2 loans: loan 1 (An Introduction to Database Systems) and loan 2 (Designing Data-Intensive Applications)' AS expected;
START TRANSACTION;
SELECT l.loan_id, b.title FROM member m
       JOIN loan l ON l.member_id = m.member_id
       JOIN copy c ON c.copy_id = l.copy_id
       JOIN book b ON b.isbn = c.isbn
       WHERE m.email = 'riya@example.com' ORDER BY l.loan_id;
ROLLBACK;

-- TC5  [Data retrieval]
-- Action:   Query available copies of 'Designing Data-Intensive Applications'
-- Expected: 1 available copy: shelf C-302 (C-301 is on loan)
SELECT 'TC5' AS test, '1 available copy: shelf C-302 (C-301 is on loan)' AS expected;
START TRANSACTION;
SELECT c.shelf_code FROM copy c JOIN book b ON b.isbn = c.isbn
       WHERE b.title = 'Designing Data-Intensive Applications'
       AND c.status = 'available' ORDER BY c.shelf_code;
ROLLBACK;

-- TC6  [Summarise related data]
-- Action:   Count total, available and on-loan copies across the library
-- Expected: 8 copies: 6 available, 2 on loan
SELECT 'TC6' AS test, '8 copies: 6 available, 2 on loan' AS expected;
START TRANSACTION;
SELECT COUNT(*) AS total, SUM(status = 'available') AS available,
       SUM(status = 'on_loan') AS on_loan FROM copy;
ROLLBACK;

-- TC7  [Alternate key (UNIQUE)]
-- Action:   Register a new member with the existing email riya@example.com
-- Expected: Rejected by uq_member_email
SELECT 'TC7' AS test, 'Rejected by uq_member_email' AS expected;
START TRANSACTION;
INSERT INTO member (full_name, email, phone) VALUES ('Duplicate', 'riya@example.com', '9111111111');
ROLLBACK;

-- TC8  [1:1 relationship (shared PK/FK)]
-- Action:   Issue a second library card to member 1
-- Expected: Rejected by the library_card primary key
SELECT 'TC8' AS test, 'Rejected by the library_card primary key' AS expected;
START TRANSACTION;
INSERT INTO library_card VALUES (1, 'LC0000000077', '2026-10-26');
ROLLBACK;

-- TC9  [CHECK constraint]
-- Action:   Insert a loan whose due date is before its issue date
-- Expected: Rejected by chk_loan_dates
SELECT 'TC9' AS test, 'Rejected by chk_loan_dates' AS expected;
START TRANSACTION;
INSERT INTO loan (copy_id, member_id, issued_on, due_on) VALUES (8, 2, '2026-10-26', '2026-10-20');
ROLLBACK;

-- TC10  [Foreign key (ON DELETE CASCADE)]
-- Action:   Delete book '9780073523323', then count its copies and author links
-- Expected: Book deleted; its 3 copies and 3 book_author rows removed automatically (0 left)
SELECT 'TC10' AS test, 'Book deleted; its 3 copies and 3 book_author rows removed automatically (0 left)' AS expected;
START TRANSACTION;
DELETE FROM book WHERE isbn = '9780073523323';
SELECT (SELECT COUNT(*) FROM copy WHERE isbn = '9780073523323') AS copies_left,
       (SELECT COUNT(*) FROM book_author WHERE isbn = '9780073523323') AS links_left,
       (SELECT COUNT(*) FROM copy) AS copies_total;
ROLLBACK;

-- TC11  [Foreign key (ON DELETE SET NULL)]
-- Action:   Delete publisher 3 (MIT Press), then look at its book
-- Expected: Book '9780262033848' is kept, with publisher_id NULL
SELECT 'TC11' AS test, 'Book ''9780262033848'' is kept, with publisher_id NULL' AS expected;
START TRANSACTION;
DELETE FROM publisher WHERE publisher_id = 3;
SELECT isbn, title, publisher_id FROM book WHERE isbn = '9780262033848';
ROLLBACK;

-- TC12  [Calculation]
-- Action:   Find overdue loans on 2026-10-26 and the fine owed at Rs 5 per day
-- Expected: 2 overdue loans: 22 days (Rs 110) and 20 days (Rs 100); total Rs 210
SELECT 'TC12' AS test, '2 overdue loans: 22 days (Rs 110) and 20 days (Rs 100); total Rs 210' AS expected;
START TRANSACTION;
SELECT l.loan_id, DATEDIFF('2026-10-26', l.due_on) AS days,
       DATEDIFF('2026-10-26', l.due_on) * 5 AS fine
       FROM loan l WHERE l.returned_on IS NULL AND l.due_on < '2026-10-26'
       ORDER BY days DESC;
ROLLBACK;
