DROP TABLE IF EXISTS issueStatus;
DROP PROCEDURE IF EXISTS getIssueStatusByProjectAndType;
DROP PROCEDURE IF EXISTS getIssueStatuses;
DROP PROCEDURE IF EXISTS getIssueStatusById;
DROP PROCEDURE IF EXISTS deleteIssueStatusById;
DROP PROCEDURE IF EXISTS createIssueStatus;
DROP PROCEDURE IF EXISTS updateIssueStatus;

CREATE TABLE issueStatus (
    id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    name VARCHAR(25) NOT NULL,
    color VARCHAR(7) NOT NULL,
    projectId INT NULL,
    typeCode VARCHAR(3) NULL,
    FOREIGN KEY (projectId) REFERENCES project(id)
);

DELIMITER //
CREATE PROCEDURE createIssueStatus(
    IN nameIn VARCHAR(25),
    IN colorIn VARCHAR(7),
    IN projectIdIn INT,
    IN typeCodeIn VARCHAR(3))
BEGIN
    INSERT INTO issueStatus(name, color, projectId, typeCode)
    VALUES (nameIn, colorIn, projectIdIn, typeCodeIn);
    SELECT LAST_INSERT_ID();
END //

CREATE PROCEDURE updateIssueStatus(
    IN idIn INT,
    IN nameIn VARCHAR(25),
    IN colorIn VARCHAR(7)
)
BEGIN
    UPDATE issueStatus SET name = nameIn, color = colorIn
    WHERE id = idIn;
END //

CREATE PROCEDURE getIssueStatusByProjectAndType(IN projectIdIn INT, IN typeCodeIn TEXT)
BEGIN
  SELECT * FROM issueStatus
    WHERE (projectIdIn IS NULL OR projectId = projectIdIn OR projectId IS NULL)
        AND (typeCodeIn IS NULL OR typeCode LIKE typeCodeIn OR typeCode IS NULL);
END //

CREATE PROCEDURE getIssueStatuses()
BEGIN
    SELECT * FROM issueStatus;
END //

CREATE PROCEDURE getIssueStatusById(IN idIn INT)
BEGIN
    SELECT * FROM issueStatus WHERE id = idIn;
END //

CREATE PROCEDURE deleteIssueStatusById(IN idIn INT)
BEGIN
    DELETE FROM issueStatus WHERE id = idIn;
END //
DELIMITER ;

INSERT INTO issueStatus (name, color, projectId, typeCode) VALUES ('Open','#27ae60',NULL,NULL);
INSERT INTO issueStatus (name, color, projectId, typeCode) VALUES ('Closed','#c0392b',NULL,NULL);
