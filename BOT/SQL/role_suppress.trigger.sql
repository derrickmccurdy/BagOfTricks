use system ;
drop trigger if exists role_suppress ;
delimiter ~


CREATE DEFINER=`admin`@`localhost` trigger role_suppress after insert on tblglobal_role
for each row
begin
	delete from datastore.tblmaster where email like NEW.role_name ;
end ;
~

delimiter ;
