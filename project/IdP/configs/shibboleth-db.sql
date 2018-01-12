SET NAMES 'utf8';

SET CHARACTER SET utf8;

CREATE DATABASE IF NOT EXISTS shibboleth CHARACTER SET=utf8;

GRANT ALL PRIVILEGES ON shibboleth.* TO root@localhost IDENTIFIED BY '';

FLUSH PRIVILEGES;

USE shibboleth;

CREATE TABLE IF NOT EXISTS shibpid
(
localEntity VARCHAR(255) NOT NULL,
peerEntity VARCHAR(255) NOT NULL,
persistentId VARCHAR(50) NOT NULL,
principalName VARCHAR(50) NOT NULL,
localId VARCHAR(50) NOT NULL,
peerProvidedId VARCHAR(50) NULL,
creationDate TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
deactivationDate TIMESTAMP NULL default NULL,
PRIMARY KEY (localEntity, peerEntity, persistentId)
);

CREATE TABLE IF NOT EXISTS StorageRecords
(
context VARCHAR(255) NOT NULL,
id VARCHAR(255) NOT NULL,
expires BIGINT(20) DEFAULT NULL,
value LONGTEXT NOT NULL,
version BIGINT(20) NOT NULL,
PRIMARY KEY (context, id)
);

USE mysql;

/* Change the value of 'demo' work with the preferred password for shibboleth DB */
/*
INSERT INTO user (Host, User, authentication_string,ssl_cipher,x509_issuer,x509_subject,Select_priv,Insert_priv,Update_priv, Delete_priv, Create_tmp_table_priv, Lock_tables_priv,Execute_priv)
VALUES ('localhost','user',PASSWORD('db_pass'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y');
*/

CREATE USER 'user'@'localhost' IDENTIFIED BY 'db_pass';
GRANT ALL PRIVILEGES ON shibboleth.* TO user@localhost;

FLUSH PRIVILEGES;
