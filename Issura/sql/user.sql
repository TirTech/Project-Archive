DROP TABLE IF EXISTS user;
DROP PROCEDURE IF EXISTS getUsers;
DROP PROCEDURE IF EXISTS getUserById;
DROP PROCEDURE IF EXISTS deleteUser;
DROP PROCEDURE IF EXISTS createUser;
DROP PROCEDURE IF EXISTS updateUser;
DROP PROCEDURE IF EXISTS getUserByUsername;
DROP PROCEDURE IF EXISTS getUsersByNamesLike;

CREATE TABLE user (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    nickname VARCHAR(50) NOT NULL
);

DELIMITER //
CREATE PROCEDURE createUser(
    IN usernameIn VARCHAR(50),
    IN nicknameIn VARCHAR(50)
)
BEGIN
    INSERT INTO user(username, nickname)
    VALUES (usernameIn, nicknameIn);
    SELECT LAST_INSERT_ID();
END //

CREATE PROCEDURE updateUser(
    IN idIn INT,
    IN nicknameIn VARCHAR(50)
)
BEGIN
    UPDATE user SET nickname = nicknameIn
    WHERE id = idIn;
END //

CREATE PROCEDURE getUsers()
BEGIN
    SELECT * FROM user;
END //

CREATE PROCEDURE getUserByUsername(IN usernameIn VARCHAR(50))
BEGIN
    SELECT * FROM user WHERE username = usernameIn;
END //

CREATE PROCEDURE getUsersByNamesLike(IN searchString VARCHAR(50))
BEGIN
    SELECT * FROM user WHERE username LIKE searchString OR nickname LIKE searchString;
END //

CREATE PROCEDURE getUserById(IN idIn INT)
BEGIN
    SELECT * FROM user WHERE id = idIn;
END //

CREATE PROCEDURE deleteUser(IN idIn INT)
BEGIN
    DELETE FROM user WHERE id = idIn;
END //
DELIMITER ;
