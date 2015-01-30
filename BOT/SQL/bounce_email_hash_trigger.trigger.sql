/*
create table if not exists datastore.domain_not_found (
id int(10) auto_increment not null primary key,
email varchar(200) not null ,
email_hash bigint(17) unsigned zerofill not null,
domain varchar(100) not null ,
Status tinyint(3) unsigned,
campaign_id int(10) not null,
key email_hash (email_hash),
key domain (domain),
key campaign_id (campaign_id)
) ;
*/


use datastore ;

drop trigger if exists bounce_email_hash_trigger ;

delimiter ~

CREATE  TRIGGER bounce_email_hash_trigger before insert on datastore.tblbounces
FOR EACH ROW
BEGIN
	if NEW.email_hash is null
	then
		set NEW.email_hash :=  datastore.email_hash(NEW.email) ;
	end if ;
	IF 85 = NEW.Status
	THEN
		insert ignore into datastore.domain_not_found (email, email_hash, domain, Status, campaign_id) values(NEW.email, NEW.email_hash, substring(NEW.email,instr(NEW.email,'@')+1), NEW.Status, NEW.campaign_id );
	END IF ;

	IF 85 <> NEW.Status
	THEN
		insert ignore into system.tblglobal_suppressed (email_hash, Status) values(NEW.email_hash, NEW.Status) ;
		insert ignore into system.tblglobal_bounces_report (custid,email,date_added,Status,email_hash,campaign_id) values(NEW.custid,NEW.email,NEW.date_added,NEW.Status,NEW.email_hash,NEW.campaign_id) ;
	END IF ;
END ;

~

delimiter ;


