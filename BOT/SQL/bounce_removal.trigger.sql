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
