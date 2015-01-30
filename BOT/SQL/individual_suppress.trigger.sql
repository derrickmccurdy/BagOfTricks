use system ;
drop trigger if exists individual_suppress ;
delimiter ~

CREATE DEFINER=`admin`@`localhost` trigger system.individual_suppress after insert on tblglobal_individual
for each row
begin
	delete from datastore.tblmaster where email_hash = conv(substr(md5(lower(NEW.email)),19,32),16,10) LIMIT 1 ;
end ;
~

delimiter ;
