# Keys and Referential Integrity in the Relational Model
### A Library Management System implemented in MySQL 8.0 and Node.js

| | |
|---|---|
| **Student** | Abhinav Ravi Shankar |
| **University Roll No.** | 25511021060094 |
| **Course** | Database Management Systems — Module 2: Designing Relational Databases |
| **Concept** | Relational Database Design, Keys & Relationships |
| **Programme** | B.Tech, Computer Science and Engineering |
| **Guide** | Kotha Sumanth, Professor, Alliance School of Advanced Computing |
| **Institution** | Alliance University, Bengaluru — October 2026 |

---

## 1. Overview

A library database with **eight related tables** — `member`, `library_card`, `publisher`, `author`, `book`, `book_author`, `copy`, `loan` — in which every rule about identity and association is declared to MySQL as a primary key, alternate key (UNIQUE), foreign key or CHECK constraint.

- **Keys:** surrogate PKs (`member_id`, `loan_id`), a natural PK (`isbn`), a composite PK (`book_author(isbn, author_id)`), alternate keys (`email`, `phone`, `shelf_code`, `card_number`).
- **Relationships:** 1:1 (member–library_card, via a shared PK/FK), 1:N (book–copy, member–loan, copy–loan, publisher–book) and M:N (book–author, via the `book_author` junction table).
- **Referential actions** chosen from business rules: `CASCADE`, `RESTRICT` and `SET NULL`.
- **10 queries** that retrieve related records, filter data and calculate results.
- **12 test cases** with expected and actual results — **12 of 12 pass**.

---

## 2. Submission contents

```
library-management-dbms/
├── README.md
├── report/
│   └── DBMS_Micro_Project_Report.pdf     ← PDF report
├── database/
│   ├── schema.sql                        ← table definitions and constraints
│   ├── data.sql                          ← seed data
│   ├── queries.sql                       ← 10 queries (related records, filters, calculations)
│   ├── test_cases.sql                    ← the 12 test cases as plain SQL
│   ├── library_db_dump.sql               ← mysqldump of the complete database (schema + data)
│   └── extras/
│       ├── verify_constraints.sql        reads back engines, PKs, FKs from information_schema
│       ├── create_app_user.sql           least-privilege account for the web app
│       ├── control_schema_nofk.sql       same database WITHOUT foreign keys (control experiment)
│       ├── destructive_workload.sql      deletions D1–D3 for the control experiment
│       └── dangling_references.sql       counts references to rows that no longer exist
├── er-diagram/
│   ├── er_diagram.png / .svg / .dot             ER diagram (Chen notation)
│   └── relational_schema.png / .svg / .dot      relational schema with PK / FK marked
├── screenshots/                          ← 25 screenshots (see section 6)
├── results/
│   ├── test_results.md                   test cases with expected and actual results
│   └── test_results.json
└── src/                                  ← Node.js source code
    ├── package.json, .env.example
    ├── db.js                             connection pool
    ├── library.js                        operations; translates constraint errors
    ├── test_cases.js                     runs the 12 test cases, records actual results
    ├── integrity_tests.js                17-operation constraint harness
    ├── control_experiment.js             FK vs no-FK comparison
    ├── server.js                         Express REST API
    └── public/index.html                 web interface
```

---

## 3. Requirements

| Software | Version |
|---|---|
| MySQL Community Server | 8.0 (InnoDB storage engine) |
| Node.js *(only for the test runner and web app)* | 20 LTS or newer |

> **InnoDB is required.** MySQL's older MyISAM engine accepts `FOREIGN KEY` clauses but silently ignores them. Every table declares `ENGINE = InnoDB`.

---

## 4. Setup

### Option A — from the SQL files

```bash
mysql -u root -p < database/schema.sql
mysql -u root -p < database/data.sql
```

### Option B — from the dump

```bash
mysql -u root -p < database/library_db_dump.sql
```

Either way you get the database `library_db` with all constraints and the seed data.

> **Windows PowerShell** does not support `<`. Use `Get-Content database\schema.sql | mysql -u root -p`, or inside the `mysql` client run `source database/schema.sql;`. In **MySQL Workbench**, open each file and run it.

---

## 5. Running

### 5.1 Queries

```bash
mysql -u root -p -t library_db < database/queries.sql
```

| # | Query | Shows |
|---|---|---|
| Q1 | All loans of one member | Related records across two 1:N relationships |
| Q2 | Each member with their library card | 1:1 relationship |
| Q3 | Every title with its authors | M:N through the junction table |
| Q4 | Available copies of database titles | Filtering |
| Q5 | Availability summary per title | COUNT / SUM / percentage |
| Q6 | Overdue loans and fines | Date arithmetic + filter |
| Q7 | Loans per member, including members with none | LEFT JOIN + GROUP BY |
| Q8 | Members who never borrowed | Anti-join (NOT EXISTS) |
| Q9 | Titles and copies per publisher | Aggregates over two joins |
| Q10 | Most borrowed titles | GROUP BY + HAVING |

Date calculations use a fixed reference date (`@as_of = '2026-10-26'`) so results are reproducible.

### 5.2 Test cases

**Plain SQL** (`--force` lets the script continue past the tests that are *expected* to be rejected):

```bash
mysql -u root -p -t --force library_db < database/test_cases.sql
```

**Automated, with expected vs actual comparison:**

```bash
cd src
npm install
cp .env.example .env               # Windows: copy .env.example .env
# run as root to see MySQL's detailed error numbers (see section 8)
DB_USER=root DB_PASSWORD=yourRootPassword npm run cases
```

This prints each test with its expected and actual result and writes `results/test_results.md` and `.json`. Every test runs inside a transaction that is rolled back, so the data is never changed.

| Test | Action | Expected | Actual | Result |
|---|---|---|---|---|
| TC1 | Insert a loan for member_id 99 (does not exist) | Rejected by fk_loan_member | Rejected: ERROR 1452 (fk_loan_member) | PASS |
| TC2 | Insert a copy of a book that does not exist | Rejected by fk_copy_book | Rejected: ERROR 1452 (fk_copy_book) | PASS |
| TC3 | Delete member 1, who has outstanding loans | Rejected (RESTRICT) | Rejected: ERROR 1451 (fk_loan_member) | PASS |
| TC4 | Query all loans of riya@example.com | 2 loans: 1 and 2 | 2 loans: 1 and 2 | PASS |
| TC5 | Available copies of *Designing Data-Intensive Applications* | 1 copy: C-302 | 1 copy: C-302 | PASS |
| TC6 | Total / available / on-loan copies | 8 / 6 / 2 | 8 / 6 / 2 | PASS |
| TC7 | New member with an existing email | Rejected by uq_member_email | Rejected: ERROR 1062 | PASS |
| TC8 | Second library card for member 1 | Rejected by library_card PK | Rejected: ERROR 1062 | PASS |
| TC9 | Loan due before it was issued | Rejected by chk_loan_dates | Rejected: ERROR 3819 | PASS |
| TC10 | Delete a book | Its 3 copies + 3 author links cascade away | 0 copies, 0 links left | PASS |
| TC11 | Delete publisher 3 | Its book kept, publisher_id NULL | Book kept, publisher_id NULL | PASS |
| TC12 | Overdue fines on 2026-10-26 at Rs 5/day | Rs 110 + Rs 100 = Rs 210 | Rs 110 + Rs 100 = Rs 210 | PASS |

### 5.3 Additional validation (optional)

```bash
# 17-operation constraint harness — needs a freshly seeded database (it changes data)
DB_USER=root DB_PASSWORD=yourRootPassword npm test

# Control experiment: the same deletions with and without foreign keys (rolled back, no changes)
mysql -u root -p < ../database/extras/control_schema_nofk.sql
DB_USER=root DB_PASSWORD=yourRootPassword npm run control
```

Harness result: 9 accepted, 8 refused, 0 unexpected. Control experiment: **9 dangling references without foreign keys, 0 with them**.

### 5.4 Web application (optional)

```bash
mysql -u root -p < ../database/extras/create_app_user.sql
npm start                          # then open http://localhost:3000
```

Register members, issue books and delete members / books / publishers; every operation shows MySQL's verdict (ACCEPTED or REFUSED).

To reset the data at any time, re-run `schema.sql` and `data.sql`.

---

## 6. Screenshots

| File | Shows |
|---|---|
| `01_er_diagram.png` | ER diagram |
| `02_relational_schema_pk_fk.png` | Relational schema with PK and FK marked |
| `03_database_created_and_seeded.png` | Tables created and row counts after seeding |
| `04_primary_and_foreign_keys_verified.png` | All tables InnoDB; the 7 foreign keys and their ON DELETE rules |
| `05_primary_unique_and_check_constraints.png` | PK, UNIQUE and CHECK constraints |
| `06_foreign_key_constraint_failure.png` | **Foreign-key failures**: non-existent member, non-existent book, RESTRICT |
| `07_key_and_check_constraint_failures.png` | Duplicate email, second card, NOT NULL and CHECK failures |
| `08`–`17_query_q1`…`q10_*.png` | Output of each query in `queries.sql` |
| `18_test_cases_1_to_6.png`, `19_test_cases_7_to_12.png` | Test cases: expected vs actual |
| `20_integrity_test_harness.png` | 17-operation harness |
| `21_control_experiment.png` | With vs without foreign keys |
| `22`–`25_web_app_*.png` | Web application: initial state, accepted operations, FK failures, CASCADE / SET NULL |

---

## 7. ER diagram summary

| Relationship | Cardinality | Implemented by | ON DELETE |
|---|---|---|---|
| member — library_card | 1 : 1 | `library_card.member_id` is both PK and FK | CASCADE |
| member — loan | 1 : N | `loan.member_id` FK | RESTRICT |
| copy — loan | 1 : N | `loan.copy_id` FK | RESTRICT |
| book — copy | 1 : N | `copy.isbn` FK | CASCADE |
| book — author | M : N | junction `book_author (isbn, author_id)`, composite PK | CASCADE (both FKs) |
| publisher — book | 1 : N | `book.publisher_id` FK (nullable) | SET NULL |

---

## 8. Note on error numbers

MySQL returns the detailed foreign-key errors **1452** / **1451** (which name the violated constraint) only to accounts with broad privileges. To the least-privilege `library_app` account used by the web app it returns the generic equivalents **1216** / **1217**. The outcome is the same — the operation is refused — and `library.js` handles both. Run the test scripts as `root` to see 1452 / 1451. On Linux, where root often uses socket authentication, add `DB_SOCKET=/var/run/mysqld/mysqld.sock`.
