use system ;
drop trigger if exists domain_suppress ;
delimiter ~


CREATE DEFINER=`admin`@`localhost` trigger domain_suppress after insert on tblglobal_domains
for each row
begin
	delete from datastore.tblmaster where domain like NEW.domain_name ;
end ;
~

delimiter ;
