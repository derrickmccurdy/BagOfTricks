
use system ;
drop trigger if exists temp_trigger_individuals ;
delimiter ~

CREATE DEFINER=`admin`@`localhost` trigger temp_trigger_individuals after insert on system.tblglobal_individual
for each row
begin
	insert into system.tblglobal_individual_new (email, email_hash, tsadded, Status) values(NEW.email, conv(substr(md5(lower(NEW.email)),19,32),16,10), NEW.tsadded, 173) ;
end ;
~

delimiter ;
