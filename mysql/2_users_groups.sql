-- Change Password of guacadmin
SET @entityid = (SELECT entity_id FROM guacamole_entity WHERE name = 'guacadmin');
SET @salt = (SELECT password_salt FROM guacamole_user WHERE entity_id = @entityid);
SET @hash = (SELECT UNHEX(SHA2(CONCAT('GUAC_ADM_PASSWORD', HEX(@salt)), 256)));

UPDATE guacamole_user
SET password_hash = @hash
WHERE entity_id = @entityid
AND password_salt = @salt;

-- Create base entity entry for User Group
INSERT INTO guacamole_entity (name, type)
VALUES ('GuacamoleUsers', 'USER_GROUP');
SET @usersEntityID = LAST_INSERT_ID();

-- Create Users Group
INSERT INTO guacamole_user_group (entity_id)
VALUES (@usersEntityID);
SET @usersGID = LAST_INSERT_ID();

-- Create base entity entry for admin Group
INSERT INTO guacamole_entity (name, type)
VALUES ('GuacamoleAdmins', 'USER_GROUP');
SET @adminsEntityID = LAST_INSERT_ID();

-- Create admins Group
INSERT INTO guacamole_user_group (entity_id)
VALUES (@adminsEntityID);
SET @adminsGID = LAST_INSERT_ID();

-- Create Connection Group for users
INSERT INTO guacamole_connection_group (connection_group_name, type)
VALUES ('LAN', 'ORGANIZATIONAL');
SET @connectionUsersGID = LAST_INSERT_ID();

-- Permission for Users group
INSERT INTO guacamole_connection_group_permission (entity_id, connection_group_id)
VALUES (@usersEntityID, @connectionUsersGID);

-- Create Connection Group for admins
INSERT INTO guacamole_connection_group (connection_group_name, type)
VALUES ('Administrative', 'ORGANIZATIONAL');
SET @connectionAdminsGID = LAST_INSERT_ID();

-- Permissions for Admins group
INSERT INTO guacamole_system_permission (entity_id, permission)
VALUES (@adminsEntityID, 'ADMINISTER');
