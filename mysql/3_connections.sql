-- Get Connectiongroup
SET @connectionUsersGID = (SELECT connection_group_id FROM guacamole_connection_group WHERE connection_group_name = 'LAN');
SET @usersEntityID = (SELECT entity_id FROM guacamole_entity WHERE name = 'GuacamoleUsers' AND type = 'USER_GROUP');
SET @connectionAdminsGID = (SELECT connection_group_id FROM guacamole_connection_group WHERE connection_group_name = 'Administrative');
SET @adminsEntityID = (SELECT entity_id FROM guacamole_entity WHERE name = 'GuacamoleAdmins' AND type = 'USER_GROUP');

-- RDP Terminal
INSERT INTO guacamole_connection (connection_name, protocol, parent_id) VALUES ('RDP Terminal', 'rdp', @connectionUsersGID);
SET @id = LAST_INSERT_ID();
INSERT INTO guacamole_connection_permission (entity_id, connection_id)
VALUES (@usersEntityID, @id);
INSERT INTO guacamole_connection_parameter VALUES (@id, 'hostname', 'Terminal');
INSERT INTO guacamole_connection_parameter VALUES (@id, 'port', '3389');
INSERT INTO guacamole_connection_parameter VALUES (@id, 'username', '${GUAC_USERNAME}');
INSERT INTO guacamole_connection_parameter VALUES (@id, 'password', '${GUAC_PASSWORD}');
INSERT INTO guacamole_connection_parameter VALUES (@id, 'domain', 'example.com');
INSERT INTO guacamole_connection_parameter VALUES (@id, 'disable-audio', 'true');
INSERT INTO guacamole_connection_parameter VALUES (@id, 'console', 'true');
INSERT INTO guacamole_connection_parameter VALUES (@id, 'server-layout', 'de-de-qwertz');
INSERT INTO guacamole_connection_parameter VALUES (@id, 'ignore-cert', 'true');
INSERT INTO guacamole_connection_parameter VALUES (@id, 'enable-drive', 'false');

-- SSH Terminal
INSERT INTO guacamole_connection (connection_name, protocol, parent_id) VALUES ('SSH Terminal', 'ssh', @connectionUsersGID);
SET @id = LAST_INSERT_ID();
INSERT INTO guacamole_connection_permission (entity_id, connection_id)
VALUES (@usersEntityID, @id);
INSERT INTO guacamole_connection_parameter VALUES (@id, 'hostname', 'Terminal');
INSERT INTO guacamole_connection_parameter VALUES (@id, 'port', '22');
INSERT INTO guacamole_connection_parameter VALUES (@id, 'username', '${GUAC_USERNAME}');
INSERT INTO guacamole_connection_parameter VALUES (@id, 'password', '${GUAC_PASSWORD}');
