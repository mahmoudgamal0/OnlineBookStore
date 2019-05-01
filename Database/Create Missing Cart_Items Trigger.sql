USE bookstore;

DELIMITER ;NOTSC

# Missing trigger
CREATE TRIGGER after_Cart_Items_update
    AFTER UPDATE ON Cart_Items
    FOR EACH ROW
BEGIN
	UPDATE Cart_Items
    SET total_price = price * quantity
    WHERE cart_id = NEW.cart_id AND ISBN = NEW.ISBN;
END;NOTSC

DELIMITER ;
