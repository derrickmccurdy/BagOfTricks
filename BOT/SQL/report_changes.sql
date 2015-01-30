
use system ;
drop trigger if exists system.suppression_abbreviate ;
delimiter ~

create trigger system.suppression_abbreviate before insert on system.tblglobal_suppressed_full
FOR EACH ROW
BEGIN
	set NEW.email_hash := datastore.email_hash(NEW.email) ;
	insert ignore into system.tblglobal_suppressed (email_hash, Status) values(NEW.email_hash, NEW.Status) ;
END ;
~
delimiter ;
/*
system.tblglobal_suppressed should get updated in real time
	should be a trigger on system.tblglobal_individual to send appropriate information to system.tblglobal_suppressed
*/
use system ;
drop trigger if exists system.tblglobal_individual_email_hash_trigger ;
delimiter ~
CREATE  TRIGGER system.tblglobal_individual_email_hash_trigger before insert on system.tblglobal_individual
FOR EACH ROW
BEGIN
        set NEW.email_hash :=  datastore.email_hash(NEW.email) ;
        SET NEW.dateadded := NOW() ;

	IF 172 = NEW.Status
	THEN
		insert ignore into system.tblglobal_suppressed_full (listid, email, email_hash, firstname, middlename, lastname, address, address2, city, county, region, zipcode, gender, companyname, jobtitle, industry, phonearea, phonenum, keywords, born, source, dtTimeStamp, ip, domain, exclude, Confirmed, ConfirmedIP, ConfirmedTS, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS, country_short, Status) values(NEW.listid, NEW.email, NEW.email_hash, NEW.firstname, NEW.middlename, NEW.lastname, NEW.address, NEW.address2, NEW.city, NEW.county, NEW.region, NEW.zipcode, NEW.gender, NEW.companyname, NEW.jobtitle, NEW.industry, NEW.phonearea, NEW.phonenum, NEW.keywords, NEW.born, NEW.source, NEW.dtTimeStamp,  NEW.ip, NEW.domain, NEW.exclude, NEW.Confirmed, NEW.ConfirmedIP, NEW.ConfirmedTS, NEW.Opener, NEW.OpenerIP, NEW.OpenerTS, NEW.Clicker, NEW.ClickerIP, NEW.ClickerTS, NEW.country_short, NEW.Status) ;
	END IF ;
END  ;
~
delimiter ;
/*
create new table system.tblglobal_bounces_report
	create trigger on datastore.tblbounces to create entries in system.tblglobal_bounces_report
	create trigger on datastore.tblbounces to create entries in system.tblglobal_suppressed
*/	
create table if not exists system.tblglobal_bounces_report like datastore.tblbounces ;
alter table system.tblglobal_bounces_report drop index email_hash ;
alter table system.tblglobal_bounces_report add unique index email_hash ;
insert ignore into system.tblglobal_bounces_report select * from datastore.tblbounces where Status in(86,87) ;

create table if not exists datastore.out_report (id int(10) auto_increment primary key, AccountID varchar(100), campaign_id varchar(100), dcount int(10)) ;

use datastore ;
drop trigger if exists bounce_email_hash_trigger ;
delimiter ~
CREATE  TRIGGER bounce_email_hash_trigger before insert on datastore.tblbounces
FOR EACH ROW
BEGIN
        set NEW.email_hash :=  datastore.email_hash(NEW.email) ;
        IF 85 = NEW.Status
        THEN
                insert ignore into datastore.domain_not_found (email, email_hash, domain, Status, campaign_id) values(NEW.email, NEW.email_hash, substring(NEW.email,instr(NEW.email,'@')+1), NEW.Status, NEW.campaign_id );
        END IF ;

        IF  NEW.Status > 85
        THEN
                insert ignore into system.tblglobal_suppressed_full (email_hash, Status) values(NEW.email_hash, NEW.Status) ;
                insert ignore into system.tblglobal_bounces_report (custid,email,Status,email_hash,campaign_id) values(NEW.custid,NEW.email,NEW.Status,NEW.email_hash,NEW.campaign_id) ;
        END IF ;
END ;
~
delimiter ;


