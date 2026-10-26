-- ===================================================================
--  library_db : queries.sql
--  Queries that retrieve related records, filter data and calculate
--  meaningful results, each walking one or more declared relationships.
--
--  Run on a freshly seeded database:
--     mysql -u root -p -t library_db < queries.sql
--
--  Date calculations use a fixed reference date (@as_of) so that the
--  results are reproducible whenever the script is run.
-- ===================================================================
USE library_db;
SET @as_of = '2026-10-26';

-- @Q1 Related records: every loan of one member (loan -> copy -> book)
-- Walks two 1:N relationships through the foreign keys loan.member_id,
-- loan.copy_id and copy.isbn.
SELECT m.full_name, l.loan_id, b.title, c.shelf_code,
       l.issued_on, l.due_on,
       COALESCE(l.returned_on, 'outstanding') AS returned_on
FROM   member m
JOIN   loan  l ON l.member_id = m.member_id
JOIN   copy  c ON c.copy_id   = l.copy_id
JOIN   book  b ON b.isbn      = c.isbn
WHERE  m.email = 'riya@example.com'
ORDER  BY l.issued_on;

-- @Q2 Related records (1:1): each member with their library card
SELECT m.member_id, m.full_name, m.email, lc.card_number, lc.issued_on AS card_issued
FROM   member m
JOIN   library_card lc ON lc.member_id = m.member_id
ORDER  BY m.member_id;

-- @Q3 Related records (M:N): every title with its authors via book_author
SELECT b.isbn, b.title,
       COALESCE(GROUP_CONCAT(CONCAT(a.author_name, ' (', ba.role, ')')
                ORDER BY ba.role DESC, a.author_name SEPARATOR ', '),
                '(no author recorded)') AS authors
FROM   book b
LEFT JOIN book_author ba ON ba.isbn = b.isbn
LEFT JOIN author a       ON a.author_id = ba.author_id
GROUP  BY b.isbn, b.title
ORDER  BY b.title;

-- @Q4 Filter: copies of database titles that are available to borrow now
SELECT c.copy_id, c.shelf_code, b.title, p.name AS publisher
FROM   copy c
JOIN   book b      ON b.isbn = c.isbn
LEFT JOIN publisher p ON p.publisher_id = b.publisher_id
WHERE  c.status = 'available'
  AND  b.title LIKE '%Database%'
ORDER  BY b.title, c.shelf_code;

-- @Q5 Calculate: availability summary per title (COUNT / SUM / ratio)
SELECT b.title,
       COUNT(c.copy_id)                              AS total_copies,
       SUM(c.status = 'available')                   AS available,
       SUM(c.status = 'on_loan')                     AS on_loan,
       CONCAT(ROUND(100 * SUM(c.status = 'available') / COUNT(c.copy_id)), '%')
                                                     AS pct_available
FROM   book b
JOIN   copy c ON c.isbn = b.isbn
GROUP  BY b.isbn, b.title
ORDER  BY available DESC, b.title;

-- @Q6 Calculate + filter: overdue loans and the fine owed (Rs 5 per day)
SELECT l.loan_id, m.full_name, b.title, l.due_on,
       DATEDIFF(@as_of, l.due_on)     AS days_overdue,
       DATEDIFF(@as_of, l.due_on) * 5 AS fine_rs
FROM   loan l
JOIN   member m ON m.member_id = l.member_id
JOIN   copy   c ON c.copy_id   = l.copy_id
JOIN   book   b ON b.isbn      = c.isbn
WHERE  l.returned_on IS NULL
  AND  l.due_on < @as_of
ORDER  BY days_overdue DESC;

-- @Q7 Calculate: borrowing activity per member, including members with
-- no loans at all (LEFT JOIN keeps them; COUNT of a NULL column is 0).
-- The outstanding test must also check loan_id, because for a member with
-- no loans the joined returned_on is NULL too.
SELECT m.member_id, m.full_name,
       COUNT(l.loan_id)                                          AS total_loans,
       SUM(l.loan_id IS NOT NULL AND l.returned_on IS NULL)      AS outstanding,
       SUM(l.returned_on IS NOT NULL)                            AS returned
FROM   member m
LEFT JOIN loan l ON l.member_id = m.member_id
GROUP  BY m.member_id, m.full_name
ORDER  BY total_loans DESC, m.member_id;

-- @Q8 Filter (anti-join): members who have never borrowed a book
SELECT m.member_id, m.full_name, m.email
FROM   member m
WHERE  NOT EXISTS (SELECT 1 FROM loan l WHERE l.member_id = m.member_id)
ORDER  BY m.member_id;

-- @Q9 Calculate: titles and copies held per publisher
SELECT p.name AS publisher,
       COUNT(DISTINCT b.isbn) AS titles,
       COUNT(c.copy_id)       AS copies
FROM   publisher p
LEFT JOIN book b ON b.publisher_id = p.publisher_id
LEFT JOIN copy c ON c.isbn = b.isbn
GROUP  BY p.publisher_id, p.name
ORDER  BY copies DESC;

-- @Q10 Calculate (HAVING): titles that have been borrowed, most popular first
SELECT b.title, COUNT(l.loan_id) AS times_borrowed,
       COUNT(DISTINCT l.member_id) AS distinct_borrowers
FROM   book b
JOIN   copy c ON c.isbn    = b.isbn
JOIN   loan l ON l.copy_id = c.copy_id
GROUP  BY b.isbn, b.title
HAVING COUNT(l.loan_id) >= 1
ORDER  BY times_borrowed DESC, b.title;
