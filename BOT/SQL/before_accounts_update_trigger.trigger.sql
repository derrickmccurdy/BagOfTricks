USE system ;

DROP TRIGGER IF EXISTS after_accounts_update_trigger ;

DELIMITER ~

CREATE TRIGGER after_accounts_update_trigger AFTER UPDATE ON system.accounts
	FOR EACH ROW
	BEGIN
		IF 1 = NEW.EmailTemplates AND 0 = OLD.EmailTemplates
		THEN
			insert into system.services_billing_item (AccountID, ID_SERVICE, DateAdded, ManagerStatus, BillingStatus, BillingReason, BillingDate, Price, OtherNotes, BillingAccountID, ExtraDetailTitle, createdBy, DateAddedSort ) values(OLD.AccountID, 116, now(), 1, 0, "Addition of Email Templates", now(), 20.00, "Charge added automatically by system.before_accounts_update_trigger SQL", OLD.BillingAccountID, "Automatic Email Template addition charge", 0, date_format(now(),'%Y-%m-%d') ) ;
--  			insert into system.services_accounts (ID_SERVICE, AccountID, LastBillDate, NextBillDate, Price,ManagerStatus,ManagerReason,DateManager,ID_FREQUENCY,BillingAccountID,AutoRenew) values(116, OLD.AccountID, date_format(now(),'%Y-%m-%d 00:00:00'),date_format(date_add(now(), interval 1 month),'%Y-%m-%d 00:00:00'), 20.00, 1, "Addition of Email Templates", now(), 1, OLD.BillingAccountID, 1) ;
 			insert into system.services_accounts (ID_SERVICE, AccountID, LastBillDate, NextBillDate, Price,ManagerStatus,ManagerReason,DateManager,ID_FREQUENCY,BillingAccountID,AutoRenew) values(116, OLD.AccountID, date_format(now(),'%Y-%m-%d 00:00:00'), (select date_format(date_add(concat(date_format(current_date(),'%Y'),'-',date_format(current_date(),'%m'),'-',date_format(dateadded, '%d')), interval 1 month),'%Y-%m-%d 00:00:00') from system.accounts where AccountID = OLD.AccountID) , 20.00, 1, "Addition of Email Templates", now(), 1, OLD.BillingAccountID, 1) ;
		END IF ;
	END ;
~

DELIMITER ;



DROP TRIGGER IF EXISTS after_accounts_insert_trigger ;

DELIMITER ~

CREATE TRIGGER after_accounts_insert_trigger AFTER insert ON system.accounts
	FOR EACH ROW
	BEGIN
		IF 1 = NEW.EmailTemplates
		THEN
			insert into system.services_billing_item (AccountID, ID_SERVICE, DateAdded, ManagerStatus, BillingStatus, BillingReason, BillingDate, Price, OtherNotes, BillingAccountID, ExtraDetailTitle, createdBy, DateAddedSort ) values(NEW.AccountID, 116, now(), 1, 0, "Addition of Email Templates", now(), 20.00, "Charge added automatically by system.before_accounts_update_trigger SQL", NEW.BillingAccountID, "Automatic Email Template addition charge", 0, date_format(now(),'%Y-%m-%d') ) ;
-- 			insert into system.services_accounts (ID_SERVICE, AccountID, LastBillDate, NextBillDate, Price,ManagerStatus,ManagerReason,DateManager,ID_FREQUENCY,BillingAccountID,AutoRenew) values(116, NEW.AccountID, date_format(now(),'%Y-%m-%d 00:00:00'),date_format(date_add(now(), interval 1 month),'%Y-%m-%d 00:00:00'), 20.00, 1, "Addition of Email Templates", now(), 1, NEW.BillingAccountID, 1) ;
 			insert into system.services_accounts (ID_SERVICE, AccountID, LastBillDate, NextBillDate, Price,ManagerStatus,ManagerReason,DateManager,ID_FREQUENCY,BillingAccountID,AutoRenew) values(116, NEW.AccountID, date_format(now(),'%Y-%m-%d 00:00:00'),(select date_format(date_add(concat(date_format(current_date(),'%Y'),'-',date_format(current_date(),'%m'),'-',date_format(dateadded, '%d')), interval 1 month),'%Y-%m-%d 00:00:00') from system.accounts where AccountID = NEW.AccountID), 20.00, 1, "Addition of Email Templates", now(), 1, NEW.BillingAccountID, 1) ;
		END IF ;
	END ;
~

DELIMITER ;



