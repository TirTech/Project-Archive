DROP TABLE IF EXISTS project;
DROP PROCEDURE IF EXISTS getProjects;
DROP PROCEDURE IF EXISTS getProjectById;
DROP PROCEDURE IF EXISTS deleteProject;
DROP PROCEDURE IF EXISTS createProject;
DROP PROCEDURE IF EXISTS updateProject;
DROP PROCEDURE IF EXISTS getProjectsByUserId;
DROP PROCEDURE IF EXISTS searchProjects;

CREATE TABLE project (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(500) NOT NULL,
    status VARCHAR(3) NOT NULL,
    ownerId INT NOT NULL,
    FOREIGN KEY (ownerId) REFERENCES user(id)
);

DELIMITER //
CREATE PROCEDURE createProject(
    IN nameIn VARCHAR(50),
    IN descriptionIn VARCHAR(500),
    IN statusIn VARCHAR(3),
    IN ownerIdIn INT
)
BEGIN
    INSERT INTO project(name, description, status, ownerId)
    VALUES (nameIn, descriptionIn, statusIn, ownerIdIn);
    SELECT LAST_INSERT_ID();
END //

CREATE PROCEDURE updateProject(
    IN idIn INT,
    IN nameIn VARCHAR(50),
    IN descriptionIn VARCHAR(500),
    IN statusIn VARCHAR(3),
    IN ownerIdIn INT
)
BEGIN
    UPDATE project SET description = descriptionIn, status = statusIn, ownerId = ownerIdIn, name = nameIn
    WHERE id = idIn;
END //

CREATE PROCEDURE getProjects()
BEGIN
    SELECT * FROM project;
END //

CREATE PROCEDURE getProjectById(IN idIn INT)
BEGIN
    SELECT * FROM project WHERE id = idIn;
END //

CREATE PROCEDURE deleteProject(IN idIn INT)
BEGIN
    DELETE FROM project WHERE id = idIn;
END //

CREATE PROCEDURE getProjectsByUserId(IN userIdIn INT)
BEGIN
    SELECT * FROM project WHERE id IN (SELECT projectId FROM projectMember WHERE userId = userIdIn) OR userIdIn = ownerId;
END //

CREATE PROCEDURE searchProjects(IN nameIn TEXT)
BEGIN
    SELECT * FROM project WHERE name LIKE nameIn;
END //

DELIMITER ;
