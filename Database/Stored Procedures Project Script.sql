USE bookstore;

DELIMITER //

CREATE PROCEDURE `register_user` (
	IN usernameIn VARCHAR(45),
    IN passwordIn CHAR(64),
    IN last_nameIn VARCHAR(45),
    IN first_nameIn VARCHAR(45),
    IN emailIn VARCHAR(45),
    IN phoneIn VARCHAR(13),
    IN shipping_addressIn VARCHAR(50),
    OUT user_id INT
)
BEGIN
	INSERT INTO Users (username, password, last_name, first_name, email, phone, shipping_address)
    VALUES (usernameIn, passwordIn, last_nameIn, first_nameIn, emailIn, phoneIn, shipping_addressIn);
    
    SET user_id = (SELECT LAST_INSERT_ID());
END//

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

CREATE PROCEDURE `login_manager_by_username` (
	IN usernameIn VARCHAR(45),
    IN passwordIn CHAR(64),
    IN emailIn VARCHAR(45),
    OUT user_id INT
)
BEGIN
	DECLARE realPassword CHAR(64);
    
    IF NOT (
		SELECT EXISTS(SELECT u.user_id, u.password INTO user_id, realPassword
			FROM Users u
			WHERE username = usernameIn
		) AND passwordIn = realPassword
	) THEN
		SET user_id = 0;
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Invalid username or password';
    END IF;
    
END//

DELIMITER ;