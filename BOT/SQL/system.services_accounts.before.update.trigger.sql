use system  ;
drop trigger if exists system_services_before_update_trigger ;
delimiter ~

create trigger system_services_before_update_trigger before update on services_accounts 
	for each row  
	begin 
		if(NEW.Removed = 1 and OLD.Removed = 0)
		then
			set NEW.AutoRenew := 0 ;
		end if ;
	END ;
~
delimiter ;

