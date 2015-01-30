USE system ;

DROP TRIGGER IF EXISTS before_accounts_update_trigger ;

DELIMITER ~

CREATE TRIGGER before_accounts_update_trigger AFTER UPDATE ON system.accounts
	FOR EACH ROW
	BEGIN
		IF 1 = NEW.emailtemplates AND 0 = OLD.emailtemplates
		THEN
			insert into system.services_billing_item (AccountID, ID_SERVICE, DateAdded, ManagerStatus, BillingStatus, BillingReason, BillingDate, Price, OtherNotes, BillingAccountID, ExtraDetailTitle, createdBy, DateAddedSort ) values(OLD.AccountID, 116, now(), 1, 0, "Addition of Email Templates", now(), 20.00, "Charge added automatically by system.before_accounts_update_trigger SQL", OLD.BillingAccountID, "Automatic Email Template addition charge", 0, date_format(now(),'%Y-%m-%d') ) ;
--			update system.accounts set ImageHosting = 1 where AccountID = OLD.AccountID ;
		END IF ;
	END ;
~

DELIMITER ;




