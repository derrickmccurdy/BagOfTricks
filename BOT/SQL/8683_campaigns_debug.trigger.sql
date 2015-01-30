use emarketing ;

drop trigger if exists emarketing.broadcaster_debug_override_trigger ;

delimiter ~

CREATE  TRIGGER emarketing.broadcaster_debug_override_trigger before insert on emarketing.campaigns 
FOR EACH ROW
BEGIN
	IF 8683 = NEW.AccountID
	THEN
		set NEW.broadcaster_debug := 1 ;
	END IF ;

END ;

~

delimiter ;


