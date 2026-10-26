-- ===================================================================
--  library_db : data.sql
--  The data every figure in Chapter III of the report is measured against.
--  Run after schema.sql.
-- ===================================================================
USE library_db;

INSERT INTO publisher (publisher_id, name) VALUES
  (1,'Pearson'), (2,'O''Reilly Media'), (3,'MIT Press');

INSERT INTO author (author_id, author_name, country) VALUES
  (1,'Abraham Silberschatz','USA'), (2,'Henry F. Korth','USA'),
  (3,'S. Sudarshan','India'),       (4,'C. J. Date','UK');

INSERT INTO book (isbn, title, publisher_id, published_yr) VALUES
  ('9780073523323','Database System Concepts',1,2019),
  ('9780321197849','An Introduction to Database Systems',1,2003),
  ('9781449373320','Designing Data-Intensive Applications',2,2017),
  ('9780262033848','Introduction to Algorithms',3,2009);

INSERT INTO book_author (isbn, author_id, role) VALUES
  ('9780073523323',1,'primary'),  ('9780073523323',2,'co-author'),
  ('9780073523323',3,'co-author'),('9780321197849',4,'primary');

INSERT INTO copy (copy_id, isbn, shelf_code) VALUES
  (1,'9780073523323','A-101'), (2,'9780073523323','A-102'),
  (3,'9780073523323','A-103'), (4,'9780321197849','B-201'),
  (5,'9780321197849','B-202'), (6,'9781449373320','C-301'),
  (7,'9781449373320','C-302'), (8,'9780262033848','D-401');

INSERT INTO member (member_id, email, phone, full_name) VALUES
  (1,'riya@example.com','9000000001','Riya Sharma'),
  (2,'omar@example.com','9000000002','Omar Khan'),
  (3,'neha@example.com','9000000003','Neha Rao'),
  (4,'ivan@example.com','9000000004','Ivan Dsouza');

INSERT INTO library_card (member_id, card_number, issued_on) VALUES
  (1,'LC0000000001','2026-01-10'), (2,'LC0000000002','2026-01-12'),
  (3,'LC0000000003','2026-02-01'), (4,'LC0000000004','2026-02-03');

-- Member 1 holds two outstanding loans. This is what makes D3 fail.
INSERT INTO loan (loan_id, copy_id, member_id, issued_on, due_on, returned_on)
VALUES
  (1,4,1,'2026-09-20','2026-10-04',NULL),
  (2,6,1,'2026-09-22','2026-10-06',NULL),
  (3,7,2,'2026-08-10','2026-08-24','2026-08-20');

-- Copies on an outstanding loan are marked as such.
UPDATE copy SET status = 'on_loan' WHERE copy_id IN (4, 6);
