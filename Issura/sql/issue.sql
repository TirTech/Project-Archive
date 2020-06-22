DROP TABLE IF EXISTS issue;
DROP PROCEDURE IF EXISTS getIssues;
DROP PROCEDURE IF EXISTS getIssueById;
DROP PROCEDURE IF EXISTS deleteIssue;
DROP PROCEDURE IF EXISTS createIssue;
DROP PROCEDURE IF EXISTS updateIssue;
DROP PROCEDURE IF EXISTS getIssuesByProjectId;
DROP PROCEDURE IF EXISTS searchIssues;
DROP PROCEDURE IF EXISTS getIssuesByUserId;

CREATE TABLE issue (
    id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description VARCHAR(500) NOT NULL,
    dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type VARCHAR(3) NOT NULL,
    statusId INT NOT NULL,
    creatorId INT NOT NULL,
    assigneeId INT NULL,
    projectId INT NOT NULL,
    FOREIGN KEY (statusId) REFERENCES issueStatus(id),
    FOREIGN KEY (creatorId) REFERENCES user(id),
    FOREIGN KEY (assigneeId) REFERENCES user(id),
    FOREIGN KEY (projectId) REFERENCES project(id)
);

DELIMITER //
CREATE PROCEDURE createIssue(
    IN titleIn VARCHAR(100),
    IN descriptionIn VARCHAR(500),
    IN typeIn VARCHAR(3),
    IN statusIdIn INT,
    IN creatorIdIn INT,
    IN assigneeIdIn INT,
    IN projectIdIn INT)
BEGIN
    INSERT INTO issue(title, description, type, statusId, creatorId, assigneeId, projectId)
    VALUES (titleIn, descriptionIn, typeIn, statusIdIn, creatorIdIn, assigneeIdIn, projectIdIn);
    SELECT LAST_INSERT_ID();
END //

CREATE PROCEDURE updateIssue(
    IN idIn INT,
    IN titleIn VARCHAR(100),
    IN descriptionIn VARCHAR(500),
    IN typeIn VARCHAR(3),
    IN statusIdIn INT,
    IN assigneeIdIn INT)
BEGIN
    UPDATE issue SET title = titleIn, description = descriptionIn, type = typeIn, statusId = statusIdIn, assigneeId = assigneeIdIn
    WHERE id = idIn;
END //

CREATE PROCEDURE getIssues()
BEGIN
    SELECT * FROM issue;
END //

CREATE PROCEDURE getIssuesByProjectId(IN projectIdIn INT)
BEGIN
    SELECT * FROM issue WHERE projectId = projectIdIn;
END //

CREATE PROCEDURE searchIssues(
    IN titleIn VARCHAR(100),
    IN descriptionIn VARCHAR(500),
    IN typeIn VARCHAR(3),
    IN statusIdIn INT,
    IN creatorIdIn INT,
    IN assigneeIdIn INT,
    IN projectIdIn INT)
BEGIN
    SELECT * FROM issue WHERE
        (ISNULL(titleIn) OR title LIKE titleIn) AND
        (ISNULL(descriptionIn) OR description LIKE descriptionIn) AND
        (ISNULL(typeIn) OR type LIKE typeIn) AND
        (ISNULL(statusIdIn) OR statusId = statusIdIn) AND
        (ISNULL(creatorIdIn) OR creatorId = creatorIdIn) AND
        (ISNULL(assigneeIdIn) OR assigneeId = assigneeIdIn) AND
        (ISNULL(projectIdIn) OR projectId = projectIdIn);
END //

CREATE PROCEDURE getIssueById(IN idIn INT)
BEGIN
    SELECT * FROM issue WHERE id = idIn;
END //

CREATE PROCEDURE deleteIssue(IN idIn INT)
BEGIN
    DELETE FROM issue WHERE id = idIn;
END //

CREATE PROCEDURE getIssuesByUserId(IN userIdIn INT)
BEGIN
   SELECT * FROM issue WHERE creatorId = userIdIn OR assigneeId = userIdIn;
END //
DELIMITER ;
