use system ;
drop trigger if exists services_billing_information_trigger ; 
delimiter ~

-- create trigger broadcaster_counter_trigger before update on derrick.campaigns 
create trigger services_billing_information_trigger before update on system.services_billing_information 
	FOR EACH ROW  
	BEGIN 
		insert into system.services_billing_information_edits (AccountID, NameOnCard, Address, City, Region, Zip, Country, CreditCardNumber, CVNumber, CreditCardType, ExpireMonth, ExpireYear, BankName, BankRoutingNumber, BankAccountNumber, Notes, removed, FirstName, LastName, MiddleName, PrimaryPaymentMethod) values(OLD.AccountID, OLD.NameOnCard, OLD.Address, OLD.City, OLD.Region, OLD.Zip, OLD.Country, OLD.CreditCardNumber, OLD.CVNumber, OLD.CreditCardType, OLD.ExpireMonth, OLD.ExpireYear, OLD.BankName, OLD.BankRoutingNumber, OLD.BankAccountNumber, OLD.Notes, OLD.removed, OLD.FirstName, OLD.LastName, OLD.MiddleName, OLD.PrimaryPaymentMethod) ;
	END ;
~

delimiter ;
