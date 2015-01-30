use leads ;
drop trigger if exists contact_forms_trigger ; 
delimiter ~

create trigger contact_forms_trigger after insert on contact_forms 
	for each row  
	begin 
		INSERT IGNORE INTO  datastore.tbldirect_optin 
		(
		listid        
		,email         
		,email_hash    
		,firstname     
		,lastname      
		,address       
		,address2      
		,city          
		,region        
		,zipcode       
		,companyname   
		,phonenum      
		,keywords      
		,source        
		,dateadded     
		,ip            
		,domain        
		,country_short 
		)
		values
		(
		99999
		,NEW.email         
		,conv(substr(md5(lower(NEW.email)),19,32),16,10)         
		,NEW.FirstName     
		,NEW.LastName      
		,NEW.Address       
		,NEW.Address2      
		,NEW.City          
		,NEW.Region        
		,NEW.Zip           
		,NEW.Employer      
		,NEW.Phone         
		,NEW.Employer     
		,concat("leads.contact_forms ",NEW.DomainName, NEW.PageName)        
		,NOW()     
		,NEW.IP        
		,substring(NEW.email, instr(NEW.email,'@')+1, length(NEW.email))
		,NEW.Country
		) ;
	END ;
~
delimiter ;

/*
select COLUMN_NAME, DATA_TYPE from information_schema.COLUMNS where TABLE_NAME = "contact_forms" and TABLE_SCHEMA = "leads";
+---------------+-----------+
| COLUMN_NAME   | DATA_TYPE |
+---------------+-----------+
| Id            | int       | 
| OrigAccountId | int       | 
| AccountId     | int       | 
| DomainName    | varchar   | 
| PageName      | varchar   | 
| Referer       | varchar   | 
| DateTime      | timestamp | 
| ReminderDate  | datetime  | 
| IP            | varchar   | 
| Email         | varchar   | 
| FirstName     | varchar   | 
| LastName      | varchar   | 
| Address       | varchar   | 
| Address2      | varchar   | 
| City          | varchar   | 
| Region        | varchar   | 
| Zip           | varchar   | 
| Country       | varchar   | 
| Phone         | varchar   | 
| Fax           | varchar   | 
| Employer      | varchar   | 
| OtherFields   | text      | 
| viewed        | tinyint   | 
| removed       | tinyint   | 
| reminder      | tinyint   | 
| Notes         | text      | 
| Label         | varchar   | 
| SessionId     | varchar   | 
| status        | enum      | 
| source        | enum      | 
+---------------+-----------+
select COLUMN_NAME, DATA_TYPE from information_schema.COLUMNS where TABLE_NAME = "tbldirect_optin" ;
+---------------+-----------+
| COLUMN_NAME   | DATA_TYPE |
+---------------+-----------+
| id            | int       | 
| listid        | int       | 
| email         | varchar   | 
| email_hash    | bigint    | 
| firstname     | varchar   | 
| middlename    | varchar   | 
| lastname      | varchar   | 
| address       | varchar   | 
| address2      | varchar   | 
| city          | varchar   | 
| county        | varchar   | 
| region        | varchar   | 
| zipcode       | varchar   | 
| gender        | varchar   | 
| companyname   | varchar   | 
| jobtitle      | varchar   | 
| industry      | varchar   | 
| phonearea     | varchar   | 
| phonenum      | varchar   | 
| keywords      | varchar   | 
| born          | date      | 
| source        | varchar   | 
| dtTimeStamp   | datetime  | 
| dateadded     | date      | 
| ip            | int       | 
| domain        | varchar   | 
| exclude       | tinyint   | 
| Confirmed     | int       | 
| ConfirmedIP   | int       | 
| ConfirmedTS   | datetime  | 
| Opener        | int       | 
| OpenerIP      | int       | 
| OpenerTS      | datetime  | 
| Clicker       | int       | 
| ClickerIP     | int       | 
| ClickerTS     | datetime  | 
| country_short | varchar   | 
+---------------+-----------+




INSERT INTO  datastore.tbldirect_optin 
		(
		listid        
		,email         
		,email_hash    
		,firstname     
		,lastname      
		,address       
		,address2      
		,city          
		,region        
		,zipcode       
		,companyname   
		,phonenum      
		,keywords      
		,source        
		,dateadded     
		,ip            
		,domain        
		,country_short 
		)
		select
		99999
		,email         
		,conv(substr(md5(lower(email)),19,32),16,10)         
		,FirstName     
		,LastName      
		,Address       
		,Address2      
		,City          
		,Region        
		,Zip           
		,Employer      
		,Phone         
		,concat(user_name, Employer)
		,concat(NEW.DomainName, NEW.PageName)        
		,NOW()     
		,IP        
		,substring(email, instr(email,'@')+1, length(email))
		,Country
		from leads.contact_forms
		 ;


*/
