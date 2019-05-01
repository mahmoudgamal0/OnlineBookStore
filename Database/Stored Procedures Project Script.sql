USE bookstore;

DELIMITER //

# Helper private procedures

CREATE PROCEDURE `is_manager` (IN id INT)
BEGIN
	IF (SELECT NOT EXISTS(SELECT * FROM Managers WHERE id = user_idOUT)) THEN
			SET user_id = 0;			
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'User is not a registered manager';
        END IF;
END//

CREATE PROCEDURE `init_cart` (
	IN user_id INT,
    OUT cart_id INT
)
BEGIN
	INSERT INTO Carts (user_id)
    VALUES (user_id);
    
    SET cart_idOUT = LAST_INSERT_ID();
END//


# Registration procedures

CREATE PROCEDURE `register_user` (
	IN usernameIn VARCHAR(45),
    IN passwordIn CHAR(64),
    IN last_nameIn VARCHAR(45),
    IN first_nameIn VARCHAR(45),
    IN emailIn VARCHAR(45),
    IN phoneIn VARCHAR(13),
    IN shipping_addressIn VARCHAR(50),
    OUT user_idOUT INT,
    OUT cart_idOUT INT
)
BEGIN
	INSERT INTO Users (username, password, last_name, first_name, email, phone, shipping_address)
    VALUES (usernameIn, passwordIn, last_nameIn, first_nameIn, emailIn, phoneIn, shipping_addressIn);
    
    SET user_idOUT = (SELECT LAST_INSERT_ID());
    
    CALL init_cart(user_idOUT, cart_idOUT);
END//

CREATE PROCEDURE `register_manager` (
	IN usernameIn VARCHAR(45),
    IN passwordIn CHAR(64),
    IN last_nameIn VARCHAR(45),
    IN first_nameIn VARCHAR(45),
    IN emailIn VARCHAR(45),
    IN phoneIn VARCHAR(13),
    IN shipping_addressIn VARCHAR(50),
    OUT user_idOUT INT,
    OUT cart_idOUT INT
)
BEGIN
	INSERT INTO Users (username, password, last_name, first_name, email, phone, shipping_address)
    VALUES (usernameIn, passwordIn, last_nameIn, first_nameIn, emailIn, phoneIn, shipping_addressIn);
    
    SET user_idOUT = (SELECT LAST_INSERT_ID());
    
    CALL init_cart(user_idOUT, cart_idOUT);
END//


# Login procedures

CREATE PROCEDURE `login_manager_by_username` (
	IN usernameIn VARCHAR(45),
    IN passwordIn CHAR(64),
    OUT user_idOUT INT,
    OUT cart_idOUT INT
)
BEGIN
	DECLARE realPassword CHAR(64);
    
    IF (SELECT EXISTS(
			SELECT user_id, password
			FROM Users u
			WHERE username = usernameIn
	)) THEN
		SELECT user_id, password
        INTO user_idOUT, realPassword
		FROM Users u
		WHERE username = usernameIn;
        IF passwordIn <> realPassword THEN
			SET user_id = 0;			
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid username or password';
		END IF;
        
        CALL is_manager(user_idOUT);
        
        CALL init_cart(user_idOUT, cart_idOUT);
    END IF;
END//

CREATE PROCEDURE `login_manager_by_email` (
	IN emailIn VARCHAR(45),
    IN passwordIn CHAR(64),
    OUT user_idOUT INT,
    OUT cart_idOUT INT
)
BEGIN
	DECLARE realPassword CHAR(64);
    
    IF (SELECT EXISTS(
			SELECT user_id, password
			FROM Users u
			WHERE email = emailIn
	)) THEN
		SELECT user_id, password
        INTO user_idOUT, realPassword
		FROM Users u
		WHERE username = usernameIn;
        IF passwordIn <> realPassword THEN
			SET user_id = 0;			
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid username or password';
		END IF;
        
        CALL is_manager(user_idOUT);
        
        CALL init_cart(user_idOUT, cart_idOUT);
    END IF;
END//

CREATE PROCEDURE `login_user_by_email` (
	IN emailIn VARCHAR(45),
    IN passwordIn CHAR(64),
    OUT user_idOUT INT,
    OUT cart_idOUT INT
)
BEGIN
	DECLARE realPassword CHAR(64);
    
    IF (SELECT EXISTS(
			SELECT user_id, password
			FROM Users u
			WHERE email = emailIn
	)) THEN
		SELECT user_id, password
        INTO user_idOUT, realPassword
		FROM Users u
		WHERE username = usernameIn;
        IF passwordIn <> realPassword THEN
			SET user_id = 0;			
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid username or password';
		END IF;
        
        CALL init_cart(user_idOUT, cart_idOUT);
    END IF;
END//

CREATE PROCEDURE `login_user_by_username` (
	IN usernameIn VARCHAR(45),
    IN passwordIn CHAR(64),
    OUT user_idOUT INT,
    OUT cart_idOUT INT
)
BEGIN
	DECLARE realPassword CHAR(64);
    
    IF (SELECT EXISTS(
			SELECT user_id, password
			FROM Users u
			WHERE username = usernameIn
	)) THEN
		SELECT user_id, password
        INTO user_idOUT, realPassword
		FROM Users u
		WHERE username = usernameIn;
        IF passwordIn <> realPassword THEN
			SET user_id = 0;			
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid username or password';
		END IF;

        CALL init_cart(user_idOUT, cart_idOUT);
    END IF;
END//

# User promotion procedures

CREATE PROCEDURE `promote_user_by_id` (IN idIn INT)
BEGIN
	INSERT INTO Managers (id)
    VALUES (idIn);
END//

CREATE PROCEDURE `promote_user_by_email` (IN emailIn VARCHAR(45))
BEGIN
	DECLARE idIn INT;
    SET idIn = (SELECT user_id FROM Users WHERE email = emailIn);
    
	INSERT INTO Managers (id)
    VALUES (idIn);
END//

CREATE PROCEDURE `promote_user_by_username` (IN usernameIn VARCHAR(45))
BEGIN
	DECLARE idIn INT;
    SET idIn = (SELECT user_id FROM Users WHERE username = usernameIn);
    
	INSERT INTO Managers (id)
    VALUES (idIn);
END//


# Manager administration procedures

CREATE PROCEDURE `add_book` (
	IN ISBNIn VARCHAR(25),
    IN titleIn VARCHAR(60),
    IN publisher_idIn INT,
    IN publication_yearIn DATE,
    IN priceIn DECIMAL,
    IN quantityIn INT,
    IN minimum_thresholdIn INT,
    IN category_idIn INT
)
BEGIN
	INSERT INTO Books (ISBN, title, publisher_id, publication_year, price, quantity, minimum_threshold, category_id)
    VALUES (ISBNIn, titleIn, publisher_idIn, publication_yearIn, priceIn, quantityIn, minimum_thresholdIn, category_idIn);
END//

CREATE PROCEDURE `modify_book` (
	IN oldISBN VARCHAR(25),
	IN ISBNIn VARCHAR(25),
    IN titleIn VARCHAR(60),
    IN publisher_idIn INT,
    IN publication_yearIn DATE,
    IN priceIn DECIMAL,
    IN quantityIn INT,
    IN minimum_thresholdIn INT,
    IN category_idIn INT
)
BEGIN
	IF oldISBN = ISBNIn THEN
		UPDATE Books
		SET
			title = titleIn,
			publisher_id = publisher_idIn,
			publication_year = publication_yearIn,
			price = priceIn,
			quantity = quantityIn,
			minimum_threshold = minimum_thresholdIn,
			category_id = category_idIn
		WHERE ISBN = oldISBN;
	ELSE 
		UPDATE Books
		SET
			ISBN = ISBNIn,
			title = titleIn,
			publisher_id = publisher_idIn,
			publication_year = publication_yearIn,
			price = priceIn,
			quantity = quantityIn,
			minimum_threshold = minimum_thresholdIn,
			category_id = category_idIn
		WHERE ISBN = oldISBN;
	END IF;
END//

CREATE PROCEDURE `confirm_order` (IN order_idIn INT)
BEGIN
	IF (SELECT EXISTS(SELECT * FROM Mng_Order WHERE order_id = order_idIn)) THEN
		UPDATE Mng_Order
        SET confirmation = TRUE
        WHERE order_id = order_idIn;
	ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Order id not found in database';
    END IF;
END//

CREATE PROCEDURE `order_books_from_publisher` (
    IN quantityIn INT,
    IN publisher_idIn INT,
    IN ISBN VARCHAR(25),
    OUT order_id INT
)
BEGIN
	INSERT INTO Mng_Order (quantity, publisher_id, ISBN)
    VALUES (quantityIn, publisher_idIn, ISBNIn);
    
    SET order_id = (SELECT LAST_INSERT_ID());
END//



DELIMITER ;