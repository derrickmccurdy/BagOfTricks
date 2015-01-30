
use datastore ;
drop trigger if exists temp_trigger_bounces ;
delimiter ~

CREATE DEFINER=`admin`@`localhost` trigger temp_trigger_bounces after insert on datastore.tblbounces
for each row
begin
	insert into datastore.tblbounces_new (custid, email, email_hash, date_added, id, Status) values(NEW.custid, NEW.email, conv(substr(md5(lower(NEW.email)),19,32),16,10), NEW.date_added, NEW.id, NEW.Status) ;
end ;
~

delimiter ;
