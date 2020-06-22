
#----[[ dropAll.sql ]]----
DROP PROCEDURE IF EXISTS getComments;
DROP PROCEDURE IF EXISTS getCommentById;
DROP PROCEDURE IF EXISTS getCommentsByIssueId;
DROP PROCEDURE IF EXISTS getIssues;
DROP PROCEDURE IF EXISTS getIssueById;
DROP PROCEDURE IF EXISTS getIssuesByProjectId;
DROP PROCEDURE IF EXISTS getIssuesByUserId;
DROP PROCEDURE IF EXISTS getIssueStatusByProjectAndType;
DROP PROCEDURE IF EXISTS getIssueStatuses;
DROP PROCEDURE IF EXISTS getIssueStatusById;
DROP PROCEDURE IF EXISTS getLinkedIssues;
DROP PROCEDURE IF EXISTS getLinkedIssueById;
DROP PROCEDURE IF EXISTS getLinkedIssuesByIssueId;
DROP PROCEDURE IF EXISTS getProjects;
DROP PROCEDURE IF EXISTS getProjectById;
DROP PROCEDURE IF EXISTS getProjectsByUserId;
DROP PROCEDURE IF EXISTS getProjectMembers;
DROP PROCEDURE IF EXISTS getProjectMemberById;
DROP PROCEDURE IF EXISTS getProjectMembersByProjectIdAndUserId;
DROP PROCEDURE IF EXISTS getProjectMembersByProjectId;
DROP PROCEDURE IF EXISTS getProjectMembersByUserId;
DROP PROCEDURE IF EXISTS getUsers;
DROP PROCEDURE IF EXISTS getUserById;
DROP PROCEDURE IF EXISTS getUserByUsername;
DROP PROCEDURE IF EXISTS getUsersByNamesLike;
DROP PROCEDURE IF EXISTS deleteComment;
DROP PROCEDURE IF EXISTS deleteIssue;
DROP PROCEDURE IF EXISTS deleteIssueStatusById;
DROP PROCEDURE IF EXISTS deleteProject;
DROP PROCEDURE IF EXISTS deleteProjectMemberById;
DROP PROCEDURE IF EXISTS deleteUser;
DROP PROCEDURE IF EXISTS deleteLinkedIssueById;
DROP PROCEDURE IF EXISTS createComment;
DROP PROCEDURE IF EXISTS createIssue;
DROP PROCEDURE IF EXISTS createIssueStatus;
DROP PROCEDURE IF EXISTS createLinkedIssue;
DROP PROCEDURE IF EXISTS createProjectMember;
DROP PROCEDURE IF EXISTS createProject;
DROP PROCEDURE IF EXISTS createUser;
DROP PROCEDURE IF EXISTS updateUser;
DROP PROCEDURE IF EXISTS updateProject;
DROP PROCEDURE IF EXISTS updateIssueStatus;
DROP PROCEDURE IF EXISTS updateIssue;
DROP PROCEDURE IF EXISTS updateComment;
DROP PROCEDURE IF EXISTS searchIssues;
DROP PROCEDURE IF EXISTS searchProjects;

DROP TABLE IF EXISTS linkedIssue;
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS issue;
DROP TABLE IF EXISTS issueStatus;
DROP TABLE IF EXISTS projectMember;
DROP TABLE IF EXISTS project;
DROP TABLE IF EXISTS user;


#----[[ user.sql ]]----
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


#----[[ project.sql ]]----
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


#----[[ issueStatus.sql ]]----
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


#----[[ issue.sql ]]----
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


#----[[ projectMember.sql ]]----
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


#----[[ comment.sql ]]----
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


#----[[ linkedIssue.sql ]]----
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

