DROP TABLE IF EXISTS projectMember;
DROP PROCEDURE IF EXISTS getProjectMembers;
DROP PROCEDURE IF EXISTS getProjectMemberById;
DROP PROCEDURE IF EXISTS deleteProjectMemberById;
DROP PROCEDURE IF EXISTS createProjectMember;
DROP PROCEDURE IF EXISTS getProjectMembersByProjectIdAndUserId;
DROP PROCEDURE IF EXISTS getProjectMembersByProjectId;
DROP PROCEDURE IF EXISTS getProjectMembersByUserId;

CREATE TABLE projectMember(
    id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    projectId INT NOT NULL,
    userId INT NOT NULL,
    FOREIGN KEY (projectId) REFERENCES project(id),
    FOREIGN KEY (userId) REFERENCES user(id)
);

DELIMITER //
CREATE PROCEDURE createProjectMember(
    IN projectIdIn INT,
    IN userIdIn INT
)
BEGIN
    INSERT INTO projectMember(projectId, userId)
    VALUES (projectIdIn, userIdIn);
    SELECT LAST_INSERT_ID();
END //

CREATE PROCEDURE getProjectMembers()
BEGIN
    SELECT * FROM projectMember;
END //

CREATE PROCEDURE getProjectMembersByUserId(
    IN userIdIn INT
)
BEGIN
    SELECT * FROM projectMember WHERE userId = userIdIn;
END //

CREATE PROCEDURE getProjectMembersByProjectIdAndUserId(
    IN projectIdIn INT,
    IN userIdIn INT
)
BEGIN
    SELECT * FROM projectMember WHERE projectId = projectIdIn AND userId = userIdIn;
END //

CREATE PROCEDURE getProjectMembersByProjectId(
    IN projectIdIn INT
)
BEGIN
    SELECT * FROM projectMember WHERE projectId = projectIdIn;
END //

CREATE PROCEDURE getProjectMemberById(IN idIn INT)
BEGIN
    SELECT * FROM projectMember WHERE id = idIn;
END //

CREATE PROCEDURE deleteProjectMemberById(IN idIn INT)
BEGIN
    DELETE FROM projectMember WHERE id = idIn;
END //
DELIMITER ;
