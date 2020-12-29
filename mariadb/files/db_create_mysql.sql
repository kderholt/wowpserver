CREATE DATABASE `MANGOS` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE DATABASE `CHARACTERS` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE DATABASE `REALMD` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE USER IF NOT EXISTS 'mangos'@'%' IDENTIFIED BY 'MANGOSUSERPASS';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES, EXECUTE, ALTER ROUTINE, CREATE ROUTINE ON `MANGOS`.* TO 'mangos'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES ON `CHARACTERS`.* TO 'mangos'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES ON `REALMD`.* TO 'mangos'@'%';


