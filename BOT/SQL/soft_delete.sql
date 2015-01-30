-- emarketing.list_deletion_log
/*
use emarketing ;

CREATE TABLE `list_deletion_log` if not exists ( 
-- local record id 
`id` int(10) NOT NULL AUTO_INCREMENT, 
-- UserID from system.users 
`user_id` int(10) NOT NULL DEFAULT '0', 
-- AccountID from system.accounts 
`AccountID` int(10) NOT NULL DEFAULT '0', 
-- ListName from emarketing.lists 
`ListName` varchar(100) DEFAULT NULL, 
-- TableID from emarketing.lists 
`TableID` varchar(40) NOT NULL, 
-- ID from emarketing.lists 
`list_id` int(10) NOT NULL DEFAULT '0', 
-- ip address user was on when delete command was issued 
`ip` varchar(20) NOT NULL, 
-- automatically updating timestamp 
`time_deleted` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
PRIMARY KEY (`id`) 
) ;
drop trigger if exists emarketing.list_removal ; 
delimiter ~
create trigger list_removal after insert on list_deletion_log 
for each row 
BEGIN 
update emarketing.lists set list_removed = 1 where ID = NEW.list_id ; 
END ; 
~
delimiter ;
*/
-- emarketing.message_deletion_log
create table if not exists emarketing.message_deletion_log  (
-- local record id 
`id` int(10) NOT NULL AUTO_INCREMENT, 
-- UserID from system.users 
`user_id` int(10) NOT NULL DEFAULT '0', 
-- AccountID from system.accounts 
`AccountID` int(10) NOT NULL DEFAULT '0', 
-- mes_name from emarketing.messages 
`mes_name` varchar(100) DEFAULT NULL, 
-- ID from emarketing.messages 
`message_id` int(10) NOT NULL DEFAULT '0', 
-- ip address user was on when delete command was issued 
`ip` varchar(20) NOT NULL, 
-- automatically updating timestamp 
`time_deleted` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
PRIMARY KEY (`id`) 
) ;
drop trigger if exists emarketing.message_removal ;
delimiter ~
create trigger emarketing.message_removal after insert on emarketing.message_deletion_log 
for each row 
BEGIN 
update emarketing.messages set removed = 1 where ID = NEW.message_id ; 
END ; 
~
delimiter ;
-- sms.message_deletion_log
use sms ;
create table if not exists sms.message_deletion_log (
-- local record id 
`id` int(10) NOT NULL AUTO_INCREMENT,
-- UserID from system.users 
`user_id` int(10) NOT NULL DEFAULT '0',
-- AccountID from system.accounts 
`AccountID` int(10) NOT NULL DEFAULT '0',
-- mes_name from sms.messages 
`mes_name` varchar(100) DEFAULT NULL,
-- ID from sms.messages 
`message_id` int(10) NOT NULL DEFAULT '0',
-- ip address user was on when delete command was issued 
`ip` varchar(20) NOT NULL,
-- automatically updating timestamp 
`time_deleted` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY (`id`)
) ;
alter table sms.messages add column removed tinyint(3) unsigned not null default 0 ;
drop trigger if exists sms.message_removal ;
delimiter ~
create trigger sms.message_removal after insert on sms.message_deletion_log
for each row
BEGIN
update sms.messages set removed = 1 where ID = NEW.message_id ;
END ;
~
delimiter ;
-- sms.list_deletion_log
use sms;
-- add the list_removed column to sms.lists table
alter table sms.lists add column list_removed tinyint(3) unsigned not null default 0 ;
CREATE TABLE if not exists sms.list_deletion_log ( 
-- local record id 
`id` int(10) NOT NULL AUTO_INCREMENT, 
-- UserID from system.users 
`user_id` int(10) NOT NULL DEFAULT '0', 
-- AccountID from system.accounts 
`AccountID` int(10) NOT NULL DEFAULT '0', 
-- ListName from sms.lists 
`ListName` varchar(100) DEFAULT NULL, 
-- TableID from sms.lists 
`TableID` varchar(40) NOT NULL, 
-- ID from sms.lists 
`list_id` int(10) NOT NULL DEFAULT '0', 
-- ip address user was on when delete command was issued 
`ip` varchar(20) NOT NULL, 
-- automatically updating timestamp 
`time_deleted` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
PRIMARY KEY (`id`) 
) ;
drop trigger if exists sms.list_removal ; 
delimiter ~
create trigger sms.list_removal after insert on sms.list_deletion_log 
for each row 
BEGIN 
	update sms.lists set list_removed = 1 where ID = NEW.list_id ; 
END ; 
~
delimiter ;
