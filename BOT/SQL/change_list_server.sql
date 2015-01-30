use emarketing ;
drop trigger if exists change_list_server ; 
delimiter ~

create trigger change_list_server before update on emarketing.settings 
	for each row  
	begin 
		SET @proceed = "" ;
		IF NEW.ListServer != OLD.ListServer 
		THEN 
			SELECT max(id), date_added, transfer_status into @id, @added, @status from emarketing.list_server_transfers where AccountID = OLD.AccountID ;
			IF @id IS NULL
			THEN
				SET @proceed = "true" ;
			ELSEIF "failed" = @status 
			THEN
				SET @proceed = "false" ;
			ELSE
				SET @proceed = "true" ;
			END IF ;

			IF "true" = @proceed
			THEN
				INSERT into list_server_transfers (former_list_server, new_list_server, AccountID, transfer_status) values (OLD.ListServer, NEW.ListServer, OLD.AccountID, "not_processed") ; 
			END IF ;
		END IF ; 
	END ;
~

delimiter ;
