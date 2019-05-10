-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema bookstore
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema bookstore
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `bookstore` DEFAULT CHARACTER SET utf8 ;
USE `bookstore` ;

-- -----------------------------------------------------
-- Table `bookstore`.`Publisher`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`Publisher` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`Publisher` (
  `publisher_id` INT NOT NULL,
  `name` VARCHAR(50) NULL,
  `address` VARCHAR(50) NULL,
  `phone` VARCHAR(13) NULL,
  PRIMARY KEY (`publisher_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`Category`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`Category` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`Category` (
  `category_id` INT NOT NULL,
  `category_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`category_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`Books`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`Books` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`Books` (
  `ISBN` VARCHAR(25) NOT NULL,
  `title` VARCHAR(60) NOT NULL,
  `publisher_id` INT NULL,
  `publication_year` DATE NULL,
  `price` DECIMAL UNSIGNED NULL,
  `quantity` INT UNSIGNED NOT NULL DEFAULT 0,
  `minimum_threshold` INT UNSIGNED NOT NULL DEFAULT 0,
  `category_id` INT NULL,
  PRIMARY KEY (`ISBN`),
  INDEX `publisher_id_idx` (`publisher_id` ASC) VISIBLE,
  INDEX `fk_Books_category_idx` (`category_id` ASC) VISIBLE,
  INDEX `title_idx` USING BTREE (`title`) VISIBLE,
  CONSTRAINT `fk_Books_publisher_id`
    FOREIGN KEY (`publisher_id`)
    REFERENCES `bookstore`.`Publisher` (`publisher_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Books_category_id`
    FOREIGN KEY (`category_id`)
    REFERENCES `bookstore`.`Category` (`category_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB
PACK_KEYS = Default;


-- -----------------------------------------------------
-- Table `bookstore`.`Book_Authors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`Book_Authors` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`Book_Authors` (
  `ISBN` VARCHAR(25) NOT NULL,
  `author_name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`author_name`, `ISBN`),
  INDEX `ISBN_idx` (`ISBN` ASC) VISIBLE,
  CONSTRAINT `fk_Book_Authors_ISBN`
    FOREIGN KEY (`ISBN`)
    REFERENCES `bookstore`.`Books` (`ISBN`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`Mng_Order`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`Mng_Order` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`Mng_Order` (
  `order_id` INT NOT NULL AUTO_INCREMENT,
  `quantity` INT NOT NULL,
  `publisher_id` INT NOT NULL,
  `ISBN` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`order_id`),
  INDEX `ISBN_idx` (`ISBN` ASC) VISIBLE,
  INDEX `publisher_id_idx` (`publisher_id` ASC) VISIBLE,
  CONSTRAINT `fk_Mng_Order_publisher_id`
    FOREIGN KEY (`publisher_id`)
    REFERENCES `bookstore`.`Publisher` (`publisher_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Mng_Order_ISBN`
    FOREIGN KEY (`ISBN`)
    REFERENCES `bookstore`.`Books` (`ISBN`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`Users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`Users` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`Users` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NOT NULL,
  `password` CHAR(64) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `first_name` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `phone` VARCHAR(13) NOT NULL,
  `shipping_address` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `username_UNIQUE` (`username` ASC) VISIBLE,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`Carts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`Carts` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`Carts` (
  `cart_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  PRIMARY KEY (`cart_id`, `user_id`),
  INDEX `fk_Carts_user_id_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_Carts_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `bookstore`.`Users` (`user_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`Cart_Items`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`Cart_Items` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`Cart_Items` (
  `cart_id` INT NOT NULL,
  `ISBN` VARCHAR(25) NOT NULL,
  `quantity` INT UNSIGNED NOT NULL,
  `price` DECIMAL UNSIGNED NOT NULL,
  PRIMARY KEY (`cart_id`, `ISBN`),
  INDEX `fk_Cart_Items_ISBN_idx` (`ISBN` ASC) VISIBLE,
  CONSTRAINT `fk_Cart_Items_cart_id`
    FOREIGN KEY (`cart_id`)
    REFERENCES `bookstore`.`Carts` (`cart_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Cart_Items_ISBN`
    FOREIGN KEY (`ISBN`)
    REFERENCES `bookstore`.`Books` (`ISBN`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`Managers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`Managers` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`Managers` (
  `id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_Managers_id`
    FOREIGN KEY (`id`)
    REFERENCES `bookstore`.`Users` (`user_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`Sales`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`Sales` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`Sales` (
  `user_id` INT NOT NULL,
  `ISBN` VARCHAR(25) NOT NULL,
  `Timestamp` DATETIME NOT NULL,
  `quantity` INT UNSIGNED NOT NULL,
  `price` DECIMAL UNSIGNED NOT NULL,
  PRIMARY KEY (`user_id`, `Timestamp`, `ISBN`),
  INDEX `fk_Sales_ISBN_idx` (`ISBN` ASC) VISIBLE,
  CONSTRAINT `fk_Sales_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `bookstore`.`Users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Sales_ISBN`
    FOREIGN KEY (`ISBN`)
    REFERENCES `bookstore`.`Books` (`ISBN`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`Visa`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`Visa` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`Visa` (
  `user_id` INT NOT NULL,
  `credit_number` VARCHAR(19) NOT NULL,
  `expiry` DATE NOT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_Visa_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `bookstore`.`Users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `bookstore`;

DELIMITER $$

USE `bookstore`$$
DROP TRIGGER IF EXISTS `bookstore`.`Books_AFTER_UPDATE` $$
USE `bookstore`$$
CREATE DEFINER = CURRENT_USER TRIGGER `bookstore`.`Books_AFTER_UPDATE` AFTER UPDATE ON `Books` FOR EACH ROW
BEGIN
	IF NEW.quantity < NEW.minimum_threshold AND OLD.quantity > NEW.minimum_threshold THEN
		INSERT INTO Mng_Order (quantity, publisher_id, ISBN)
        VALUES (NEW.minimum_threshold, NEW.publisher_id, NEW.ISBN);
    END IF;
END$$


USE `bookstore`$$
DROP TRIGGER IF EXISTS `bookstore`.`Mng_Order_BEFORE_DELETE` $$
USE `bookstore`$$
CREATE DEFINER = CURRENT_USER TRIGGER `bookstore`.`Mng_Order_BEFORE_DELETE` BEFORE DELETE ON `Mng_Order` FOR EACH ROW
BEGIN
	UPDATE Books
    SET quantity = quantity + OLD.quantity
    WHERE ISBN = OLD.ISBN;
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `bookstore`.`Category`
-- -----------------------------------------------------
START TRANSACTION;
USE `bookstore`;
INSERT INTO `bookstore`.`Category` (`category_id`, `category_name`) VALUES (1, 'Science');
INSERT INTO `bookstore`.`Category` (`category_id`, `category_name`) VALUES (2, 'Art');
INSERT INTO `bookstore`.`Category` (`category_id`, `category_name`) VALUES (3, 'Religion');
INSERT INTO `bookstore`.`Category` (`category_id`, `category_name`) VALUES (4, 'History');
INSERT INTO `bookstore`.`Category` (`category_id`, `category_name`) VALUES (5, 'Geography');

COMMIT;

