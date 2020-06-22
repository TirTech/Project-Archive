DROP TABLE IF EXISTS comment;
DROP PROCEDURE IF EXISTS getComments;
DROP PROCEDURE IF EXISTS getCommentById;
DROP PROCEDURE IF EXISTS getCommentsByIssueId;
DROP PROCEDURE IF EXISTS deleteComment;
DROP PROCEDURE IF EXISTS createComment;
DROP PROCEDURE IF EXISTS updateComment;

CREATE TABLE comment(
    id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    creatorId INT NOT NULL,
    text VARCHAR(500) NOT NULL,
    issueId INT NOT NULL,
    dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (creatorId) REFERENCES user(id),
    FOREIGN KEY (issueId) REFERENCES issue(id)
);

DELIMITER //
CREATE PROCEDURE createComment(
    IN creatorIdIn INT,
    IN textIn VARCHAR(500),
    IN issueIdIn INT)
BEGIN
    INSERT INTO comment(creatorId, issueId, text) VALUES (creatorIdIn, issueIdIn, textIn);
    SELECT LAST_INSERT_ID();
END //

CREATE PROCEDURE updateComment(
    IN idIn INT,
    IN textIn VARCHAR(500))
BEGIN
    UPDATE comment SET text = textIn WHERE id = idIn;
END //

CREATE PROCEDURE getComments()
BEGIN
    SELECT * FROM comment;
END //

CREATE PROCEDURE getCommentsByIssueId(IN idIn INT)
BEGIN
    SELECT * FROM comment WHERE issueId = idIn;
END //

CREATE PROCEDURE getCommentById(IN idIn INT)
BEGIN
    SELECT * FROM comment WHERE id = idIn;
END //

CREATE PROCEDURE deleteComment(IN idIn INT)
BEGIN
    DELETE FROM comment WHERE id = idIn;
END //
DELIMITER ;
