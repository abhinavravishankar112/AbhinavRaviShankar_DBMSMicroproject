-- ===================================================================
--  library_db : schema.sql
--  Keys and Referential Integrity in the Relational Model
--  Library Management System - MySQL 8.0 / InnoDB
--
--  Every identity rule and every relationship rule in this file is
--  declared to the server. No integrity check lives in application code.
-- ===================================================================
DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db CHARACTER SET utf8mb4;
USE library_db;

-- ---------- Strong entity, surrogate PK, two alternate keys ----------
CREATE TABLE member (
    member_id  INT          AUTO_INCREMENT,
    email      VARCHAR(100) NOT NULL,
    phone      CHAR(10)     NOT NULL,
    full_name  VARCHAR(80)  NOT NULL,
    joined_on  DATE         NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT pk_member       PRIMARY KEY (member_id),
    CONSTRAINT uq_member_email UNIQUE (email),   -- candidate key
    CONSTRAINT uq_member_phone UNIQUE (phone)    -- candidate key
) ENGINE = InnoDB;

-- ---------- 1:1 -- the child's PK is also its FK ----------
-- Because member_id is the PRIMARY KEY of this relation it can occur at
-- most once, so "a member holds at most one card" needs no extra rule.
CREATE TABLE library_card (
    member_id   INT      NOT NULL,
    card_number CHAR(12) NOT NULL,
    issued_on   DATE     NOT NULL,
    CONSTRAINT pk_card        PRIMARY KEY (member_id),
    CONSTRAINT uq_card_no     UNIQUE (card_number),
    CONSTRAINT fk_card_member FOREIGN KEY (member_id)
        REFERENCES member (member_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE publisher (
    publisher_id INT         AUTO_INCREMENT,
    name         VARCHAR(80) NOT NULL,
    CONSTRAINT pk_publisher      PRIMARY KEY (publisher_id),
    CONSTRAINT uq_publisher_name UNIQUE (name)
) ENGINE = InnoDB;

CREATE TABLE author (
    author_id   INT         AUTO_INCREMENT,
    author_name VARCHAR(80) NOT NULL,
    country     VARCHAR(50),
    CONSTRAINT pk_author PRIMARY KEY (author_id)
) ENGINE = InnoDB;

-- ---------- Natural PK; optional attribution via SET NULL ----------
CREATE TABLE book (
    isbn         CHAR(13)     NOT NULL,     -- natural key: unique, stable
    title        VARCHAR(150) NOT NULL,
    publisher_id INT          NULL,         -- nullable: SET NULL needs it
    published_yr SMALLINT,
    CONSTRAINT pk_book PRIMARY KEY (isbn),
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id)
        REFERENCES publisher (publisher_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------- M:N resolved by a junction relation ----------
-- The COMPOSITE primary key is what stops the same pair being
-- recorded twice; neither column is unique on its own.
CREATE TABLE book_author (
    isbn      CHAR(13) NOT NULL,
    author_id INT      NOT NULL,
    role      ENUM('primary','co-author','editor') NOT NULL DEFAULT 'primary',
    CONSTRAINT pk_book_author PRIMARY KEY (isbn, author_id),
    CONSTRAINT fk_ba_book   FOREIGN KEY (isbn)
        REFERENCES book (isbn)        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ba_author FOREIGN KEY (author_id)
        REFERENCES author (author_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------- 1:N, existence-dependent child ----------
CREATE TABLE copy (
    copy_id    INT         AUTO_INCREMENT,
    isbn       CHAR(13)    NOT NULL,
    shelf_code VARCHAR(10) NOT NULL,
    status     ENUM('available','on_loan','lost') NOT NULL DEFAULT 'available',
    CONSTRAINT pk_copy       PRIMARY KEY (copy_id),
    CONSTRAINT uq_copy_shelf UNIQUE (shelf_code),   -- candidate key
    CONSTRAINT fk_copy_book  FOREIGN KEY (isbn)
        REFERENCES book (isbn)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------- Associative entity: has attributes, so it gets its own PK ----
-- A composite key on (copy_id, member_id) would be wrong: the same member
-- may borrow the same copy again next year, and that is a second loan.
CREATE TABLE loan (
    loan_id     INT  AUTO_INCREMENT,
    copy_id     INT  NOT NULL,
    member_id   INT  NOT NULL,
    issued_on   DATE NOT NULL,
    due_on      DATE NOT NULL,
    returned_on DATE NULL,
    CONSTRAINT pk_loan PRIMARY KEY (loan_id),
    CONSTRAINT fk_loan_copy   FOREIGN KEY (copy_id)
        REFERENCES copy (copy_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_loan_member FOREIGN KEY (member_id)
        REFERENCES member (member_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_loan_dates CHECK (due_on >= issued_on)
) ENGINE = InnoDB;
