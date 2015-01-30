use system ;
-- system.accounts
-- system.domains

drop trigger if exists system_accounts_after_update_trigger ; 
delimiter ~

create trigger system_accounts_after_update_trigger after update on system.accounts 
	for each row  
	begin 
		if NEW.notes <> OLD.notes
		then
			update system.domains set notes = NEW.notes where accountid = OLD.accountid ;
		end if ;
	END ;
~
delimiter ;

