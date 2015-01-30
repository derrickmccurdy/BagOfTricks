use emarketing ;

drop trigger if exists emarketing.remove_campaign_trigger ;
drop trigger if exists emarketing.before_campaign_update_trigger ;

delimiter ~

CREATE  TRIGGER emarketing.before_campaign_update_trigger before update on emarketing.campaigns 
FOR EACH ROW
BEGIN
	IF NEW.schedule < NOW() and OLD.statusint in('700','100','0')
	THEN
		set NEW.schedule := NOW() ;
	END IF ;

	IF 1 = NEW.removed and 0 = OLD.removed
	THEN
		set NEW.statusInt := '900' ;
	END IF ;

-- 	IF '400' = NEW.statusInt
-- 	THEN
-- 		update emarketing.lists set num_of_sends = num_of_sends + 1 where list_removed = 0 and Accountid = NEW.AccountID and TableID = NEW.ListID ;
--	END IF ;

END ;

~

delimiter ;

