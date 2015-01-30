use ecom  ;
drop trigger if exists ecom_orders_trigger ; 
delimiter ~

create trigger ecom_orders_trigger after insert on orders 
	for each row  
	begin 
		INSERT IGNORE INTO  datastore.tbldirect_optin 
			listid        
			,email         
			,email_hash    
			,firstname     
			,middlename    
			,lastname      
			,address       
			,address2      
			,city          
			,region        
			,zipcode       
			,country_short 
			,phonenum      
			,keywords
			,source        
			)
			values
			( 
			99999
			,NEW.BillEmail            
			,conv(substr(md5(lower(NEW.BillEmail)),19,32),16,10)
			,NEW.BillFirstName        
			,NEW.BillMiddleName       
			,NEW.BillLastName         
			,NEW.BillAddress1         
			,NEW.BillAddress2         
			,NEW.BillCity             
			,NEW.BillRegion           
			,NEW.BillZip              
			,NEW.BillCountry          
			,NEW.BillPhone            
			,NEW.BillCompany          
			,concat("ecom.orders AccountID=", NEW.AccountID," CustomerID =",NEW.CustomerID)           
			) ;
	END ;
~
delimiter ;

/*
select COLUMN_NAME, DATA_TYPE from information_schema.COLUMNS where TABLE_NAME = "orders" and TABLE_SCHEMA = "ecom";
+----------------------+------------+
| COLUMN_NAME          | DATA_TYPE  |
+----------------------+------------+
| ID                   | bigint     | 
| AccountID            | int        | 
| CustomerID           | int        | 
| AffiliateID          | varchar    | 
| TransactionID        | varchar    | 
| TransactionType      | varchar    | 
| PromoCode            | varchar    | 
| ShippingTrackingCode | varchar    | 
| ShippingMethod       | varchar    | 
| CustomOrderID        | varchar    | 
| CurrentStatus        | enum       | 
| TimeLastUpdated      | timestamp  | 
| TimeOrdered          | timestamp  | 
| TimeCompleted        | timestamp  | 
| TimeCanceled         | timestamp  | 
| ShippingTotal        | float      | 
| AdditionalShipping   | float      | 
| TaxTotal             | float      | 
| DiscountTotal        | float      | 
| BillEmail            | varchar    | 
| BillFirstName        | varchar    | 
| BillMiddleName       | varchar    | 
| BillLastName         | varchar    | 
| BillCompany          | varchar    | 
| BillAddress1         | varchar    | 
| BillAddress2         | varchar    | 
| BillCity             | varchar    | 
| BillRegion           | varchar    | 
| BillZip              | varchar    | 
| BillCountry          | char       | 
| BillPhone            | varchar    | 
| ShipFirstName        | varchar    | 
| ShipLastName         | varchar    | 
| ShipCompany          | varchar    | 
| ShipAddress1         | varchar    | 
| ShipAddress2         | varchar    | 
| ShipCity             | varchar    | 
| ShipRegion           | varchar    | 
| ShipZip              | varchar    | 
| ShipCountry          | char       | 
| ShipPhone            | varchar    | 
| CCType               | varchar    | 
| CCNum                | varchar    | 
| CCCVV                | char       | 
| CCExpMon             | varchar    | 
| CCExpYear            | year       | 
| Comments             | mediumtext | 
| removed              | tinyint    | 
| canceled_reason      | mediumtext | 
| otherFields          | text       | 
| BillMethod           | varchar    | 

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

select COLUMN_NAME, DATA_TYPE from information_schema.COLUMNS where TABLE_NAME = "tbldirect_optin" ;
+---------------+-----------+
| COLUMN_NAME   | DATA_TYPE |
+---------------+-----------+
insert ignore into datastore.tbldirect_optin
(
listid        
,email         
,email_hash    
,firstname     
,middlename    
,lastname      
,address       
,address2      
,city          
,region        
,zipcode       
,country_short 
,phonenum      
,keywords
,source        
)
select
99999
,BillEmail            
,conv(substr(md5(lower(BillEmail)),19,32),16,10)
,BillFirstName        
,BillMiddleName       
,BillLastName         
,BillAddress1         
,BillAddress2         
,BillCity             
,BillRegion           
,BillZip              
,BillCountry          
,BillPhone            
,BillCompany          
,concat("ecom.orders AccountID=", AccountID," CustomerID =",CustomerID)           
from ecom.orders ;




*/
