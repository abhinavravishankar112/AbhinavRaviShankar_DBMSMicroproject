-- ===================================================================
--  library_db_dump.sql  -  full MySQL dump (schema + seed data)
--  Generated with mysqldump from MySQL 8.0. Recreates the complete
--  database, including every key, foreign key and CHECK constraint:
--     mysql -u root -p < library_db_dump.sql
-- ===================================================================

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

/*!40000 DROP DATABASE IF EXISTS `library_db`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `library_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `library_db`;
DROP TABLE IF EXISTS `author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `author` (
  `author_id` int NOT NULL AUTO_INCREMENT,
  `author_name` varchar(80) NOT NULL,
  `country` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`author_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `author` WRITE;
/*!40000 ALTER TABLE `author` DISABLE KEYS */;
INSERT INTO `author` VALUES (1,'Abraham Silberschatz','USA'),(2,'Henry F. Korth','USA'),(3,'S. Sudarshan','India'),(4,'C. J. Date','UK');
/*!40000 ALTER TABLE `author` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book` (
  `isbn` char(13) NOT NULL,
  `title` varchar(150) NOT NULL,
  `publisher_id` int DEFAULT NULL,
  `published_yr` smallint DEFAULT NULL,
  PRIMARY KEY (`isbn`),
  KEY `fk_book_publisher` (`publisher_id`),
  CONSTRAINT `fk_book_publisher` FOREIGN KEY (`publisher_id`) REFERENCES `publisher` (`publisher_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `book` WRITE;
/*!40000 ALTER TABLE `book` DISABLE KEYS */;
INSERT INTO `book` VALUES ('9780073523323','Database System Concepts',1,2019),('9780262033848','Introduction to Algorithms',3,2009),('9780321197849','An Introduction to Database Systems',1,2003),('9781449373320','Designing Data-Intensive Applications',2,2017);
/*!40000 ALTER TABLE `book` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `book_author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book_author` (
  `isbn` char(13) NOT NULL,
  `author_id` int NOT NULL,
  `role` enum('primary','co-author','editor') NOT NULL DEFAULT 'primary',
  PRIMARY KEY (`isbn`,`author_id`),
  KEY `fk_ba_author` (`author_id`),
  CONSTRAINT `fk_ba_author` FOREIGN KEY (`author_id`) REFERENCES `author` (`author_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ba_book` FOREIGN KEY (`isbn`) REFERENCES `book` (`isbn`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `book_author` WRITE;
/*!40000 ALTER TABLE `book_author` DISABLE KEYS */;
INSERT INTO `book_author` VALUES ('9780073523323',1,'primary'),('9780073523323',2,'co-author'),('9780073523323',3,'co-author'),('9780321197849',4,'primary');
/*!40000 ALTER TABLE `book_author` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `copy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `copy` (
  `copy_id` int NOT NULL AUTO_INCREMENT,
  `isbn` char(13) NOT NULL,
  `shelf_code` varchar(10) NOT NULL,
  `status` enum('available','on_loan','lost') NOT NULL DEFAULT 'available',
  PRIMARY KEY (`copy_id`),
  UNIQUE KEY `uq_copy_shelf` (`shelf_code`),
  KEY `fk_copy_book` (`isbn`),
  CONSTRAINT `fk_copy_book` FOREIGN KEY (`isbn`) REFERENCES `book` (`isbn`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `copy` WRITE;
/*!40000 ALTER TABLE `copy` DISABLE KEYS */;
INSERT INTO `copy` VALUES (1,'9780073523323','A-101','available'),(2,'9780073523323','A-102','available'),(3,'9780073523323','A-103','available'),(4,'9780321197849','B-201','on_loan'),(5,'9780321197849','B-202','available'),(6,'9781449373320','C-301','on_loan'),(7,'9781449373320','C-302','available'),(8,'9780262033848','D-401','available');
/*!40000 ALTER TABLE `copy` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `library_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `library_card` (
  `member_id` int NOT NULL,
  `card_number` char(12) NOT NULL,
  `issued_on` date NOT NULL,
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `uq_card_no` (`card_number`),
  CONSTRAINT `fk_card_member` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `library_card` WRITE;
/*!40000 ALTER TABLE `library_card` DISABLE KEYS */;
INSERT INTO `library_card` VALUES (1,'LC0000000001','2026-01-10'),(2,'LC0000000002','2026-01-12'),(3,'LC0000000003','2026-02-01'),(4,'LC0000000004','2026-02-03');
/*!40000 ALTER TABLE `library_card` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `loan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan` (
  `loan_id` int NOT NULL AUTO_INCREMENT,
  `copy_id` int NOT NULL,
  `member_id` int NOT NULL,
  `issued_on` date NOT NULL,
  `due_on` date NOT NULL,
  `returned_on` date DEFAULT NULL,
  PRIMARY KEY (`loan_id`),
  KEY `fk_loan_copy` (`copy_id`),
  KEY `fk_loan_member` (`member_id`),
  CONSTRAINT `fk_loan_copy` FOREIGN KEY (`copy_id`) REFERENCES `copy` (`copy_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_loan_member` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_loan_dates` CHECK ((`due_on` >= `issued_on`))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `loan` WRITE;
/*!40000 ALTER TABLE `loan` DISABLE KEYS */;
INSERT INTO `loan` VALUES (1,4,1,'2026-09-20','2026-10-04',NULL),(2,6,1,'2026-09-22','2026-10-06',NULL),(3,7,2,'2026-08-10','2026-08-24','2026-08-20');
/*!40000 ALTER TABLE `loan` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member` (
  `member_id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `phone` char(10) NOT NULL,
  `full_name` varchar(80) NOT NULL,
  `joined_on` date NOT NULL DEFAULT (curdate()),
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `uq_member_email` (`email`),
  UNIQUE KEY `uq_member_phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `member` WRITE;
/*!40000 ALTER TABLE `member` DISABLE KEYS */;
INSERT INTO `member` VALUES (1,'riya@example.com','9000000001','Riya Sharma','2026-10-26'),(2,'omar@example.com','9000000002','Omar Khan','2026-10-26'),(3,'neha@example.com','9000000003','Neha Rao','2026-10-26'),(4,'ivan@example.com','9000000004','Ivan Dsouza','2026-10-26');
/*!40000 ALTER TABLE `member` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `publisher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `publisher` (
  `publisher_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`publisher_id`),
  UNIQUE KEY `uq_publisher_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `publisher` WRITE;
/*!40000 ALTER TABLE `publisher` DISABLE KEYS */;
INSERT INTO `publisher` VALUES (3,'MIT Press'),(2,'O\'Reilly Media'),(1,'Pearson');
/*!40000 ALTER TABLE `publisher` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

