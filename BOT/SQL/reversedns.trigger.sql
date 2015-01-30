/*
CREATE TABLE `reversedns` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `AccountID` int(10) NOT NULL DEFAULT '0',
  `ip` varchar(200) NOT NULL,
  `domain` varchar(200) NOT NULL,
  `removed` tinyint(1) NOT NULL DEFAULT '0',
  `dateAdded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastUpdated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `removedIndex` (`removed`,`AccountID`,`ip`,`domain`),
  KEY `ipDomain` (`AccountID`,`ip`,`domain`),
  KEY `timeIndex` (`removed`,`dateAdded`,`lastUpdated`)
)
*/

-- select concat(SUBSTRING_INDEX( '123.12.13.124' , '.', -1 ),'.',SUBSTRING_INDEX(SUBSTRING_INDEX( '123.12.13.124' , '.', -2 ),'.',1),'.',SUBSTRING_INDEX(SUBSTRING_INDEX( '123.12.13.124' , '.', 2 ),'.',-1),'.',substring_index('123.12.13.124','.',1)) ;
use system ;
drop trigger if exists system.reversedns_before_insert ;
delimiter ~

create trigger system.reversedns_before_insert before insert on system.reversedns
for each row
begin

	set NEW.reverse_ip := concat(SUBSTRING_INDEX( NEW.ip , '.', -1 ),'.',SUBSTRING_INDEX(SUBSTRING_INDEX( NEW.ip , '.', -2 ),'.',1),'.',SUBSTRING_INDEX(SUBSTRING_INDEX( NEW.ip , '.', 2 ),'.',-1),'.',substring_index(NEW.ip,'.',1)) ;
-- 	reverse(NEW.ip) ;

end ;
~
delimiter ;




/*
use datastore ;
drop trigger if exists bounce_removal ;
delimiter ~

CREATE DEFINER=`admin`@`localhost` trigger bounce_removal after insert on datastore.tblbounces
for each row
begin
        delete from tblmaster where email_hash = conv(substr(md5(lower(NEW.email)),19,32),16,10) LIMIT 1 ;
end ;
~

delimiter ;
*/ 
