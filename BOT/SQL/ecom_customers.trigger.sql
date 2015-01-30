use ecom  ;
drop trigger if exists ecom_customers_trigger ; 
delimiter ~

create trigger ecom_customers_trigger after insert on customers 
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
		,NEW.Address1       
		,NEW.Address2      
		,NEW.City          
		,NEW.Region        
		,NEW.Zip           
		,NEW.Company      
		,NEW.Phone         
		,concat("ecom.customers ",NEW.Company)      
		,"ecom.customers"
		,NOW()     
		,substring(NEW.email, instr(NEW.email,'@')+1, length(NEW.email))
		,NEW.Country
		) ;

	END ;
~

delimiter ;

/*
select COLUMN_NAME, DATA_TYPE from information_schema.COLUMNS where TABLE_NAME = "contact_forms" and TABLE_SCHEMA = "leads";
+--------------+-----------+
| COLUMN_NAME  | DATA_TYPE |
+--------------+-----------+
| ID           | int       | 
| AccountID    | int       | 
| FirstName    | varchar   | 
| MiddleName   | varchar   | 
| LastName     | varchar   | 
| Company      | varchar   | 
| Address1     | varchar   | 
| Address2     | varchar   | 
| City         | varchar   | 
| Region       | varchar   | 
| Zip          | varchar   | 
| Country      | varchar   | 
| Phone        | varchar   | 
| Email        | varchar   | 
| Password     | varchar   | 
| active       | tinyint   | 
| TimeAdded    | timestamp | 
| removed      | tinyint   | 
| member       | tinyint   | 
| premium      | tinyint   | 
| discount     | float     | 
| taxexempt    | tinyint   | 
| openaccount  | tinyint   | 
| creditstatus | tinyint   | 
+--------------+-----------+

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
		,domain        
		,country_short 
		)
		select 99999
		,email         
		,conv(substr(md5(lower(email)),19,32),16,10)         
		,FirstName     
		,LastName      
		,Address1       
		,Address2      
		,City          
		,Region        
		,Zip           
		,Company      
		,Phone         
		,Company
		,"ecom.customer"
		,NOW()     
		,substring(email, instr(email,'@')+1, length(email))
		,Country
		from ecom.customers
		 ;
*/
