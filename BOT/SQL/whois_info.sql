-- drop table if exists system.whois_info ;

create table if not exists system.whois_info ( id int(10) auto_increment primary key, AccountID int(10) not null default 0, userid int(10) not null default 0 , created_date timestamp DEFAULT CURRENT_TIMESTAMP, ip varchar(20) not null, BusinessName varchar(95) not null, Address varchar(60) not null, City varchar(60) not null, Region varchar(20) not null, Zip varchar(15) not null, Country varchar(40) not null, Phone varchar(20) not null, account_type enum("email", "sms") );


delimiter ~
-- input_created_date

/*

CREATE TABLE `whois_info` (
  `id` int(10) auto_increment primary key
  `AccountID` int(10) NOT NULL DEFAULT '0',
  `userid` int(10) NOT NULL DEFAULT '0',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip` varchar(20) NOT NULL,
  `BusinessName` varchar(95) NOT NULL,
  `Address` varchar(60) NOT NULL,
  `City` varchar(60) NOT NULL,
  `Region` varchar(20) NOT NULL,
  `Zip` varchar(15) NOT NULL,
  `Country` varchar(40) NOT NULL,
  `Phone` varchar(20) NOT NULL,
  `account_type` enum('email','sms') DEFAULT NULL
)


*/

drop function if exists system.do_whois_info ;

-- create function system.do_whois_info (input_AccountID int(10), input_userid int(10), input_ip varchar(20), input_BusinessName varchar(95), input_Address varchar(60), input_City varchar(60), input_Region varchar(20), input_Zip varchar(15), input_Country varchar(40), input_Phone varchar(20), input_account_type varchar(10)) returns varchar(10) MODIFIES SQL DATA
create function system.do_whois_info (input_AccountID int(10), input_userid int(10), input_ip varchar(20), input_BusinessName varchar(95), input_Address varchar(60), input_City varchar(60), input_Region varchar(20), input_Zip varchar(15), input_Country varchar(40), input_Phone varchar(20), input_account_type varchar(10)) returns varchar(10) DETERMINISTIC
BEGIN
	declare previous_entries int(10) default 0 ;
	declare emarketing_or_sms varchar(10) default "email" ;
	declare dBillingAccountID int(10) default 0 ;

 
-- get the count of any previous entries in this table for that account_id and account_type
--	select @previous_entries := count(AccountID) from system.whois_info where account_type = input_account_type and AccountID = input_AccountID ;
	select count(AccountID) into previous_entries from system.whois_info where account_type = input_account_type and AccountID = input_AccountID ;
-- set internal variable to be "emarketing" by default
-- if the input_account_type is sms, change it...
	if input_account_type = "sms"
	then
		SET emarketing_or_sms := "sms" ;
	end if ;


	if previous_entries < 1
	then
		if emarketing_or_sms = "email"
		then
			insert into system.whois_info (AccountID, BusinessName, Address, City, Region, Zip, Country, Phone, account_type) select AccountID, BusinessName, Address, City, Region, Zip, Country, Phone, "email" from emarketing.settings where AccountID = input_AccountID ;

			insert into system.whois_info (AccountID, userid, ip, account_type, BusinessName, Address, City, Region, Zip, Country, Phone) values(input_AccountID, input_userid, input_ip, input_account_type, input_BusinessName, input_Address, input_City, input_Region, input_Zip, input_Country, input_Phone) ;

			update emarketing.settings set BusinessName = input_BusinessName, Address = input_Address, City = input_City, Region = input_Region, Zip = input_Zip, Country = input_Country, Phone = input_Phone where AccountID = input_AccountID ;
			return "false" ;
		else
			insert into system.whois_info (AccountID, BusinessName, Address, City, Region, Zip, Country, Phone, account_type) select AccountID, BusinessName, Address, City, Region, Zip, Country, Phone, "sms" from sms.settings where AccountID = input_AccountID ;

			insert into system.whois_info (AccountID, userid, ip, account_type, BusinessName, Address, City, Region, Zip, Country, Phone) values(input_AccountID, input_userid, input_ip, input_account_type, input_BusinessName, input_Address, input_City, input_Region, input_Zip, input_Country, input_Phone) ;

			update sms.settings set BusinessName = input_BusinessName, Address = input_Address, City = input_City, Region = input_Region, Zip = input_Zip, Country = input_Country, Phone = input_Phone where AccountID = input_AccountID ;
			return "false" ;

		end if ;
	else
		insert into system.whois_info (AccountID, BusinessName, Address, City, Region, Zip, Country, Phone, account_type, ip) values(input_AccountID, input_BusinessName, input_Address, input_City, input_Region, input_Zip, input_Country, input_Phone, emarketing_or_sms, input_ip) ;
		if emarketing_or_sms = "email"
		then
			update emarketing.settings set BusinessName = input_BusinessName, Address = input_Address, City = input_City, Region = input_Region, Zip = input_Zip, Country = input_Country, Phone = input_Phone where AccountID = input_AccountID ;
		else
			update sms.settings set BusinessName = input_BusinessName, Address = input_Address, City = input_City, Region = input_Region, Zip = input_Zip, Country = input_Country, Phone = input_Phone where AccountID = input_AccountID ;
		end if ;
-- 34 $50
		select BillingAccountID into dBillingAccountID from system.accounts where AccountID = input_AccountID ;

		insert into system.services_billing_item (AccountID, ID_SERVICE, DateAdded, ManagerStatus, BillingStatus, BillingReason, BillingDate, Price, OtherNotes, BillingAccountID, ExtraDetailTitle, createdBy, DateAddedSort ) values(input_AccountID, 34, now(), 1, 0, "self help whois info change", now(), 50.00, "charge added automatically by do_whois_info SQL function", dBillingAccountID, "Automatic whois info change charge", 0, date_format(now(),'%Y-%m-%d') ) ;
		return "true" ;
	end if ;
END ;

~

delimiter ;


