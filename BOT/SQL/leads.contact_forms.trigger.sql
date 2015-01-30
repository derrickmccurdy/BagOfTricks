/*
Create a copy of leads.contact_forms to be used as an archive.
Create a trigger to insert a new record into this archive table each time a record is updated.

Create an event 
	that will run once per day
	that will reassign the lead to a different sales representative 
		if the sales rep does not close the lead,
		if the sale rep does not "touch" the lead twice in seven days
			(count() where accountid = $x and touchdate > date_sub(now(), interval 7 day)) < 2 && 
		Once it has been assigned to all sales reps and still never been closed, assign to house sales account.


*/

 CREATE TABLE if not exists leads.contact_forms_archive (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `orig_Id` int(10) unsigned NOT NULL,
  `OrigAccountId` int(10) unsigned NOT NULL,
  `AccountId` int(11) DEFAULT NULL,
  `DomainName` varchar(255) DEFAULT NULL,
  `PageName` varchar(255) DEFAULT NULL,
  `Referer` varchar(255) DEFAULT NULL,
  `archive_created` timestamp not null default current_timestamp,
  `DateTime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ReminderDate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `IP` varchar(255) DEFAULT NULL,
  `Email` varchar(255) DEFAULT NULL,
  `FirstName` varchar(255) DEFAULT NULL,
  `LastName` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `Address2` varchar(255) DEFAULT NULL,
  `City` varchar(255) DEFAULT NULL,
  `Region` varchar(255) DEFAULT NULL,
  `Zip` varchar(20) DEFAULT NULL,
  `Country` varchar(255) DEFAULT NULL,
  `Phone` varchar(255) DEFAULT NULL,
  `Fax` varchar(255) DEFAULT NULL,
  `Employer` varchar(255) DEFAULT NULL,
  `OtherFields` text,
  `viewed` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `removed` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `reminder` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `Notes` text NOT NULL,
  `Label` varchar(255) NOT NULL,
  `SessionId` varchar(70) NOT NULL,
  `status` enum('Open','Contacted','Closed','Dead','Duplicate','Inbound') NOT NULL DEFAULT 'Open',
  `source` enum('Cold Call','Existing Customer','Self Generated','Employee','Partner','Direct Mail','Conference','Trade Show','Search Engine','Word of Mouth','Email Marketing','SMS Marketing','Website','Other','Referral') NOT NULL DEFAULT 'Website',
  `ReportDomain` varchar(255) DEFAULT NULL,
  `CampaignID` int(10) DEFAULT '0',
  `EmailID` int(10) DEFAULT '0',
  `producttype` enum('Unknown','Email Marketing','SMS Marketing','Web Development','Guardian Angel','Signup','SEO','Fax Marketing') NOT NULL DEFAULT 'Unknown',
  `rating` enum('Hot','Warm','Cold') NOT NULL DEFAULT 'Cold',
  `RecycledAM` int(10) DEFAULT NULL,
  `Company` varchar(255) DEFAULT NULL,
  `isFolder` tinyint(4) unsigned NOT NULL DEFAULT '0',
  `FolderParent` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Id`),
  key `orig_Id` (`AccountId`,`orig_Id`,`DateTime`),
  KEY `AccountId` (`AccountId`),
  KEY `removed` (`removed`),
  KEY `Label` (`Label`),
  KEY `SessionId` (`SessionId`),
  KEY `status` (`status`),
  KEY `source` (`source`),
  KEY `DateTime` (`DateTime`),
  KEY `OrigAccountId` (`OrigAccountId`),
  KEY `producttype` (`producttype`),
  FULLTEXT KEY `DomainName` (`DomainName`,`IP`,`Email`,`FirstName`,`LastName`)
) ;

drop trigger if exists leads.before_update_contact_forms ;

delimiter ~

CREATE trigger leads.before_update_contact_forms before update on leads.contact_forms
for each row  
begin 
	if 2 = OLD.OrigAccountId
	then 
		insert ignore into leads.contact_forms_archive (orig_Id,OrigAccountId,AccountId,DomainName,PageName,Referer,archive_created,DateTime,ReminderDate,IP,Email,FirstName,LastName,Address,Address2,City,Region,Zip,Country,Phone,Fax,Employer,OtherFields,viewed,removed,reminder,Notes,Label,SessionId,status,source,ReportDomain,CampaignID,EmailID,producttype,rating,RecycledAM,Company,isFolder,FolderParent) values(
			OLD.Id
			,OLD.OrigAccountId
			,OLD.AccountId
			,OLD.DomainName
			,OLD.PageName
			,OLD.Referer
			,now()
			,OLD.DateTime
			,OLD.ReminderDate
			,OLD.IP
			,OLD.Email
			,OLD.FirstName
			,OLD.LastName
			,OLD.Address
			,OLD.Address2
			,OLD.City
			,OLD.Region
			,OLD.Zip
			,OLD.Country
			,OLD.Phone
			,OLD.Fax
			,OLD.Employer
			,OLD.OtherFields
			,OLD.viewed
			,OLD.removed
			,OLD.reminder
			,OLD.Notes
			,OLD.Label
			,OLD.SessionId
			,OLD.status
			,OLD.source
			,OLD.ReportDomain
			,OLD.CampaignID
			,OLD.EmailID
			,OLD.producttype
			,OLD.rating
			,OLD.RecycledAM
			,OLD.Company
			,OLD.isFolder
			,OLD.FolderParent
		) ;
	end if ;
end ;

~


drop event if exists leads.reassign_leads ~

create event leads.reassign_leads ON SCHEDULE EVERY 1 day STARTS '2011-02-04 01:12:00' ON COMPLETION PRESERVE enable COMMENT 'reassign leads to house account after 7 days' 
DO BEGIN
        call leads.reassign_leads() ;
END ;

~

drop procedure if exists leads.reassign_leads ~

create procedure leads.reassign_leads()
BEGIN
        DECLARE done INT DEFAULT 0 ;
        declare acctid int default 0 ;
	declare original_lead_id int default 0 ;
	declare ddcount int default 0 ;

-- 	find leads that have been in the possession of an account rep at least seven days that have been updated fewer than two times in that period and that were originally from accountid 2 and the account rep is definitely an expedite employee
	declare cur1 CURSOR for select cf.orig_Id, count(*) -1 as dcount, cf.accountid from leads.contact_forms_archive as cf inner join system.accounts as a on cf.origaccountid = 2 and cf.accountid = a.accountid and a.groupid = 20 inner join system.users as u on u.accountid = a.accountid and u.removed = 0 group by cf.orig_id, cf.accountid having dcount < 2 and min(cf.archive_created) < date_sub(now(), interval 7 day) ;

	open cur1 ;

	repeat
		fetch cur1 into original_lead_id, ddcount, acctid ;
		set @original_lead_id := original_lead_id ;
		set @acctid := acctid ;
		set @ddcount := ddcount ;

		if "" <> @original_lead_id
		then
-- 		reset back to accountid 2.
			set @update_lead_string := concat("update leads.contact_forms set accountid = 2 where id = ", @original_lead_id) ;
			prepare update_lead_statement from @update_lead_string ;
			execute update_lead_statement ;
			deallocate prepare update_lead_statement ;
			
		else
			set done := 1 ;
		end if ;

	until 1 = done 
	end repeat ;
	close cur1 ;

END ;

~


delimiter ;

