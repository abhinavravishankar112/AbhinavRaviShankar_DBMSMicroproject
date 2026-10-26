# Test results

Run on 2026-10-26 against a freshly seeded `library_db`.

| Test | Category | Action | Expected | Actual | Result |
|---|---|---|---|---|---|
| TC1 | Foreign key constraint | Insert a loan for member_id 99, which does not exist | Rejected by fk_loan_member | Rejected: ERROR 1452 ER_NO_REFERENCED_ROW_2 (fk_loan_member) | PASS |
| TC2 | Foreign key constraint | Insert a copy of ISBN '9789999999999', a book that does not exist | Rejected by fk_copy_book | Rejected: ERROR 1452 ER_NO_REFERENCED_ROW_2 (fk_copy_book) | PASS |
| TC3 | Foreign key (ON DELETE RESTRICT) | Delete member 1, who has two outstanding loans | Rejected by fk_loan_member; nothing deleted | Rejected: ERROR 1451 ER_ROW_IS_REFERENCED_2 (fk_loan_member) | PASS |
| TC4 | Related records | Query all loans of the member riya@example.com | 2 loans: loan 1 (An Introduction to Database Systems) and loan 2 (Designing Data-Intensive Applications) | 2 loans: loan 1 (An Introduction to Database Systems) and loan 2 (Designing Data-Intensive Applications) | PASS |
| TC5 | Data retrieval | Query available copies of 'Designing Data-Intensive Applications' | 1 available copy: shelf C-302 (C-301 is on loan) | 1 available copy: shelf C-302 | PASS |
| TC6 | Summarise related data | Count total, available and on-loan copies across the library | 8 copies: 6 available, 2 on loan | 8 copies: 6 available, 2 on loan | PASS |
| TC7 | Alternate key (UNIQUE) | Register a new member with the existing email riya@example.com | Rejected by uq_member_email | Rejected: ERROR 1062 ER_DUP_ENTRY (member.uq_member_email) | PASS |
| TC8 | 1:1 relationship (shared PK/FK) | Issue a second library card to member 1 | Rejected by the library_card primary key | Rejected: ERROR 1062 ER_DUP_ENTRY (library_card.PRIMARY) | PASS |
| TC9 | CHECK constraint | Insert a loan whose due date is before its issue date | Rejected by chk_loan_dates | Rejected: ERROR 3819 ER_CHECK_CONSTRAINT_VIOLATED (chk_loan_dates) | PASS |
| TC10 | Foreign key (ON DELETE CASCADE) | Delete book '9780073523323', then count its copies and author links | Book deleted; its 3 copies and 3 book_author rows removed automatically (0 left) | Book deleted; 0 copies and 0 book_author rows left (library now holds 5 copies, was 8) | PASS |
| TC11 | Foreign key (ON DELETE SET NULL) | Delete publisher 3 (MIT Press), then look at its book | Book '9780262033848' is kept, with publisher_id NULL | Book '9780262033848' is kept, with publisher_id NULL | PASS |
| TC12 | Calculation | Find overdue loans on 2026-10-26 and the fine owed at Rs 5 per day | 2 overdue loans: 22 days (Rs 110) and 20 days (Rs 100); total Rs 210 | 2 overdue loans: 22 days (Rs 110) and 20 days (Rs 100); total Rs 210 | PASS |

**12 of 12 passed.**
