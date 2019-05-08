USE `bookstore`;

DELIMITER $$

DROP TRIGGER IF EXISTS bookstore.Cart_Items_AFTER_UPDATE$$
USE `bookstore`$$
CREATE DEFINER=`root`@`localhost` TRIGGER `bookstore`.`Cart_Items_AFTER_UPDATE` 
BEFORE UPDATE ON `Cart_Items` FOR EACH ROW
set new.total_price = new.price * new.quantity;$$
DELIMITER ;
