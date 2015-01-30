use  $daccountid ;
drop trigger if exists $daccountid.reset_status ; 
delimiter ~

CREATE trigger $accountid.reset_status before update on $accountid.$tableid
for each row
begin
	set NEW.status := 0 ;
end ;
~

delimiter ;
