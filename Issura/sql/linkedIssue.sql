DROP TABLE IF EXISTS linkedIssue;
DROP PROCEDURE IF EXISTS getLinkedIssues;
DROP PROCEDURE IF EXISTS getLinkedIssueById;
DROP PROCEDURE IF EXISTS getLinkedIssuesByIssueId;
DROP PROCEDURE IF EXISTS deleteLinkedIssueById;
DROP PROCEDURE IF EXISTS createLinkedIssue;

CREATE TABLE linkedIssue(
    id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    parentIssueId INT NOT NULL,
    childIssueId INT NOT NULL,
    FOREIGN KEY (parentIssueId) REFERENCES issue(id),
    FOREIGN KEY (childIssueId) REFERENCES issue(id)
);

DELIMITER //
CREATE PROCEDURE createLinkedIssue(
    IN parentIssueIdIn INT,
    IN childIssueIdIn INT
)
BEGIN
    INSERT INTO linkedIssue(parentIssueId, childIssueId)
    VALUES (parentIssueIdIn, childIssueIdIn);
    SELECT LAST_INSERT_ID();
END //

CREATE PROCEDURE getLinkedIssues()
BEGIN
    SELECT * FROM linkedIssue;
END //

CREATE PROCEDURE getLinkedIssueById(IN idIn INT)
BEGIN
    SELECT * FROM linkedIssue WHERE id = idIn;
END //

CREATE PROCEDURE getLinkedIssuesByIssueId(IN issueIdIn INT)
BEGIN
    SELECT * FROM linkedIssue WHERE parentIssueId = issueIdIn OR childIssueId = issueIdIn;
END //

CREATE PROCEDURE deleteLinkedIssueById(IN idIn INT)
BEGIN
    DELETE FROM linkedIssue WHERE id = idIn;
END //
DELIMITER ;
