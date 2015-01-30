/*
BOT/SQL/master_event.event.sql

This event performs several tasks on a daily schedule at a time when the impact on system performance is least noticable

It suppresses and removes records from datastore.tblmaster
	individual suppression	- system.tblglobal_individual
	bounce suppression	- datastore.tblbounces
	domain suppression	- system.tblglobal_domains
	role suppression	- system.tblglobal_role


It copies records to datastore.tbldirect_optin
	contact forms		- from leads.contact_forms
	ecommerce customers	- from ecom.customers
	ecommerce orders	- from ecom.orders

It suppresses everything in datastore.tbldirect_optin before moving to the next step

It inserts records into datastore.tblmaster from datastore.tbldirect_optin
	textusave		- textusave already writes date to datastore.tbldirect_optins
	leads.contcact_forms	- 
	ecom.customers		- 
	ecom.orders		- 
	
It truncates datastore.tbldirect_optin after it has inserted everything that it can into datastore.tblmaster
*/


use datastore ;
drop event if exists master_daily_event ;
delimiter ~

CREATE EVENT master_daily_event ON SCHEDULE EVERY 1 DAY STARTS '2009-03-19 01:12:00' ON COMPLETION PRESERVE ENABLE COMMENT 'add, remove and report on records in datastore.tblmaster' 
DO BEGIN


-- 	SUBTRACTION

-- 	individual suppression
	SET @aff_rows = 0 ;
	SELECT @prior_count := count(*) from datastore.tblmaster ;
	SELECT @records := count(*) from system.tblglobal_individual ;
-- 	fill the email_hash
	UPDATE system.tblglobal_individual set email_hash = conv(substr(md5(lower(email)),19,32),16,10) where email_hash = 0 or email_hash is null ;
-- 	individual data retention
	REPLACE  INTO system.tblglobal_individual (listid, email, firstname, middlename, lastname, address, address2, city, county, region, zipcode, gender, companyname, jobtitle, industry, phonearea, phonenum, keywords, born, source, dtTimeStamp, dateadded, ip, domain, exclude, Confirmed, ConfirmedIP, ConfirmedTS, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS, country_short, Status) select master.listid, master.email, master.firstname, master.middlename, master.lastname, master.address, master.address2, master.city, master.county, master.region, master.zipcode, master.gender, master.companyname, master.jobtitle, master.industry, master.phonearea, master.phonenum, master.keywords, master.born, master.source, master.dtTimeStamp, master.dateadded, master.ip, master.domain, master.exclude, master.Confirmed, master.ConfirmedIP, master.ConfirmedTS, master.Opener, master.OpenerIP, master.OpenerTS, master.Clicker, master.ClickerIP, master.ClickerTS, master.country_short, 173 from datastore.tblmaster as master inner join system.tblglobal_individual as individuals on master.email_hash = individuals.email_hash where DATE_FORMAT(individuals.tsadded,'%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),'%Y-%m-%d') ;
-- 	suppress the individuals
	DELETE datastore.tblmaster as master from datastore.tblmaster as master inner join system.tblglobal_individual as individual on individual.email_hash = master.email_hash where individual.Status = 173 AND DATE_FORMAT(individual.tsAdded,'%Y-%m-%d') =  DATE_FORMAT(DATE_SUB(current_date(), INTERVAL 1 DAY),'%Y-%m-%d') ;
-- 	record for reporting
	SET @description = "individual_suppression" ;
	SELECT @post_count := count(*) FROM datastore.tblmaster ;
	SELECT @aff_rows := @prior_count - @post_count ;
	INSERT INTO datastore.record_reports (dateadded, table_name,records,affected_rows,prior_count, post_count,description) values(now(), "tblglobal_individual", @records, @aff_rows, @prior_count, @post_count, @description) ;


-- 	bounce suppression
	SET @aff_rows = 0 ;
	SELECT @prior_count := count(*) from datastore.tblmaster ;
	SELECT @records := count(*) from datastore.tblbounces ;

	delete from datastore.tblbounces where 1 = email regexp '^[0-9]*$' ;
-- 	fill the email_hash
	UPDATE datastore.tblbounces set email_hash = conv(substr(md5(lower(email)),19,32),16,10) where email_hash = 0 or email_hash is null;
-- 	bounce data retention
	INSERT INTO system.tblglobal_individual (listid, email, email_hash, firstname, middlename, lastname, address, address2, city, county, region, zipcode, gender, companyname, jobtitle, industry, phonearea, phonenum, keywords, born, source, dtTimeStamp, dateadded, ip, domain, exclude, Confirmed, ConfirmedIP, ConfirmedTS, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS, country_short, Status) select master.listid, master.email, master.email_hash, master.firstname, master.middlename, master.lastname, master.address, master.address2, master.city, master.county, master.region, master.zipcode, master.gender, master.companyname, master.jobtitle, master.industry, master.phonearea, master.phonenum, master.keywords, master.born, master.source, master.dtTimeStamp, master.dateadded, master.ip, master.domain, master.exclude, master.Confirmed, master.ConfirmedIP, master.ConfirmedTS, master.Opener, master.OpenerIP, master.OpenerTS, master.Clicker, master.ClickerIP, master.ClickerTS, master.country_short, bounces.Status from datastore.tblmaster as master inner join datastore.tblbounces as bounces on master.email_hash = bounces.email_hash where DATE_FORMAT(bounces.date_added,'%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),'%Y-%m-%d') ON DUPLICATE KEY UPDATE listid = master.listid, firstname = master.firstname, middlename = master.middlename, lastname = master.lastname, address = master.address, address2 = master.address2, city = master.city, county = master.county, region = master.region, zipcode = master.zipcode, gender = master.gender, companyname = master.companyname, jobtitle = master.jobtitle , industry = master.industry, phonearea = master.phonearea, phonenum = master.phonenum, keywords = master.keywords, born = master.born, source = master.source, dtTimeStamp = master.dtTimeStamp, dateadded = master.dateadded, ip = master.ip, domain = master.domain, exclude = master.exclude, Confirmed = master.Confirmed, ConfirmedIP = master.ConfirmedIP, ConfirmedTS = master.ConfirmedTS, Opener = master.Opener, OpenerIP = master.OpenerIP, OpenerTS = master.OpenerTS, Clicker = master.Clicker, ClickerIP = master.ClickerIP, ClickerTS = master.ClickerTS, country_short = master.country_short, Status = bounces.Status ;
-- 	suppress the bounces
	DELETE datastore.tblmaster as master from datastore.tblmaster as master inner join datastore.tblbounces as bounces on bounces.email_hash = master.email_hash where DATE_FORMAT(bounces.date_added,'%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),'%Y-%m-%d')  ;
-- 	record for reporting
	SET @description = "bounce_removal" ;
	SELECT @post_count := count(*) FROM datastore.tblmaster ;
	SELECT @aff_rows := @prior_count - @post_count ;
	INSERT INTO datastore.record_reports (dateadded, table_name,records,affected_rows,prior_count, post_count,description) values(now(), "tblbounces", @records, @aff_rows, @prior_count, @post_count, @description) ;


-- 	domain suppression
	SET @aff_rows = 0 ;
	SELECT @prior_count := count(*) from datastore.tblmaster ;
	SELECT @records := count(*) from system.tblglobal_domains ;
-- 	get newly added domain names
        SELECT group_concat(domain_name separator ";") from system.tblglobal_domains where DATE_FORMAT(tsAdded,'%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),'%Y-%m-%d')  into @domain_wildcards ;

        IF @domain_wildcards IS NOT NULL
        THEN
-- 		domain data retention		
		SET @domain_retention_string2 = CONCAT("INSERT INTO system.tblglobal_individual (listid, email, email_hash, firstname, middlename, lastname, address, address2, city, county, region, zipcode, gender, companyname, jobtitle, industry, phonearea, phonenum, keywords, born, source, dtTimeStamp, dateadded, ip, domain, exclude, Confirmed, ConfirmedIP, ConfirmedTS, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS, country_short, Status) select master.listid, master.email, master.email_hash, master.firstname, master.middlename, master.lastname, master.address, master.address2, master.city, master.county, master.region, master.zipcode, master.gender, master.companyname, master.jobtitle, master.industry, master.phonearea, master.phonenum, master.keywords, master.born, master.source, master.dtTimeStamp, master.dateadded, master.ip, master.domain, master.exclude, master.Confirmed, master.ConfirmedIP, master.ConfirmedTS, master.Opener, master.OpenerIP, master.OpenerTS, master.Clicker, master.ClickerIP, master.ClickerTS, master.country_short, 171 from datastore.tblmaster as master where (email like \"", REPLACE(@domain_wildcards, ";", "\" or email like \""), "\" ) ON DUPLICATE KEY UPDATE listid = master.listid, firstname = master.firstname, middlename = master.middlename, lastname = master.lastname, address = master.address, address2 = master.address2, city = master.city, county = master.county, region = master.region, zipcode = master.zipcode, gender = master.gender, companyname = master.companyname, jobtitle = master.jobtitle, industry = master.industry, phonearea = master.phonearea, phonenum = master.phonenum, keywords = master.keywords, born = master.born, source = master.source, dtTimeStamp = master.dtTimeStamp, dateadded = master.dateadded, ip = master.ip, domain = master.domain, exclude = master.exclude, Confirmed = master.Confirmed, ConfirmedIP = master.ConfirmedIP, ConfirmedTS = master.ConfirmedTS, Opener = master.Opener, OpenerIP = master.OpenerIP, OpenerTS = master.OpenerTS, Clicker = master.Clicker, ClickerIP = master.ClickerIP, ClickerTS = master.ClickerTS, country_short = master.country_short, Status = 171" ) ;
		PREPARE domain_retention_statement2 FROM @domain_retenton_string2 ;
                EXECUTE domain_retention_statement2 ;
                DEALLOCATE PREPARE domain_retention_statement2 ;
-- 		suppress the domains
                SET @domain_string2 = CONCAT("DELETE FROM datastore.tblmaster where (email like \"", REPLACE(@domain_wildcards, ";", "\" or email like \""), "\" )" ) ;
                PREPARE domain_statement2 FROM @domain_string2 ;
                EXECUTE domain_statement2 ;
                DEALLOCATE PREPARE domain_statement2 ;

        END IF ;
-- 	record for reporting
	SET @description = "domain_suppression" ;
	SELECT @post_count := count(*) FROM datastore.tblmaster ;
	SELECT @aff_rows := @prior_count - @post_count ;
	INSERT INTO datastore.record_reports (dateadded, table_name,records,affected_rows,prior_count, post_count,description) values(now(), "tblglobal_domains", @records, @aff_rows, @prior_count, @post_count, @description) ;


-- 	role suppression
	SET @aff_rows = 0 ;
	SELECT @prior_count := count(*) from datastore.tblmaster ;
	SELECT @records := count(*) from system.tblglobal_role ;
-- 	get newly added roles
        SELECT group_concat(role_name separator ";") from system.tblglobal_role where DATE_FORMAT(tsAdded, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(current_date(), INTERVAL 1 DAY), '%Y-%m-%d')  into @roles ;

        IF @roles IS NOT NULL
        THEN
-- 		role data retention		
		SET @role_retention_string = CONCAT("INSERT INTO system.tblglobal_individual (listid, email, email_hash, firstname, middlename, lastname, address, address2, city, county, region, zipcode, gender, companyname, jobtitle, industry, phonearea, phonenum, keywords, born, source, dtTimeStamp, dateadded, ip, domain, exclude, Confirmed, ConfirmedIP, ConfirmedTS, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS, country_short, Status) select master.listid, master.email, master.email_hash, master.firstname, master.middlename, master.lastname, master.address, master.address2, master.city, master.county, master.region, master.zipcode, master.gender, master.companyname, master.jobtitle, master.industry, master.phonearea, master.phonenum, master.keywords, master.born, master.source, master.dtTimeStamp, master.dateadded, master.ip, master.domain, master.exclude, master.Confirmed, master.ConfirmedIP, master.ConfirmedTS, master.Opener, master.OpenerIP, master.OpenerTS, master.Clicker, master.ClickerIP, master.ClickerTS, master.country_short, 172 from datastore.tblmaster as master where (email like \"", REPLACE(@roles, ";", "\" or email like \""), "\" ) ON DUPLICATE KEY UPDATE listid = master.listid, firstname = master.firstname, middlename=master.middlename, lastname = master.lastname, address = master.address, address2 = master.address2, city= master.city, county = master.county, region = master.region, zipcode = master.zipcode, gender = master.gender , companyname = master.companyname, jobtitle = master.jobtitle, industry = master.industry, phonearea = master.phonearea, phonenum = master.phonenum, keywords = master.keywords, born = master.born, source = master.source, dtTimeStamp = master.dtTimeStamp, dateadded = master.dateadded, ip = master.ip, domain = master.domain, exclude = master.exclude, Confirmed = master.Confirmed, ConfirmedIP = master.ConfirmedIP, ConfirmedTS = master.ConfirmedTS, Opener = master.Opener, OpenerIP = master.OpenerIP, OpenerTS = master.OpenerTS, Clicker = master.Clicker, ClickerIP = master.ClickerIP, ClickerTS = master.ClickerTS, country_short = master.country_short, Status = 172" ) ;
		PREPARE role_retention_statement FROM @role_retenton_string ;
                EXECUTE role_retention_statement ;
                DEALLOCATE PREPARE role_retention_statement ;
-- 		suppress the roles
                SET @role_string = CONCAT("DELETE FROM datastore.tblmaster where (email like \"", REPLACE(@roles, ";", "\" or email like \""), "\" )" ) ;
                PREPARE role_statement FROM @role_string ;
                EXECUTE role_statement ;
                DEALLOCATE PREPARE role_statement ;

        END IF ;
-- 	record for reporting
	SET @description = "role_suppression" ;
	SELECT @post_count := count(*) FROM datastore.tblmaster ;
	SELECT @aff_rows := @prior_count - @post_count ;
	INSERT INTO datastore.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "tblglobal_role", @records, @aff_rows, @prior_count, @post_count, @description) ;

-- 	COPY DATA


-- 	textusave
-- 	textusave already writes its records to datastore.tbldirect_optin
	
-- 	leads.contact_forms
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
                SELECT 
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
			,Employer
			,concat("leads.contact_forms ",DomainName, PageName)
			,NOW()
			,IP
			,substring(email, instr(email,'@')+1, length(email))
			,Country
                FROM leads.contact_forms WHERE DATE_FORMAT(DateTime, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d') ;


-- 	ecom.customers
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
			SELECT 
				99999
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
				,CONCAT("ecom.customers AccountID=",AccountID)
				,NOW()
				,substring(email, instr(email,'@')+1, length(email))
				,Country
			FROM ecom.customers WHERE DATE_FORMAT(TimeAdded,'%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d') ;


-- 	ecom.orders
                INSERT IGNORE INTO  datastore.tbldirect_optin
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
                        SELECT
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
                        FROM ecom.orders where DATE_FORMAT(TimeOrdered, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d') ;


	
-- 	run suppression on datastore.tbldirect_optin before copying into master dataset.
--	call datastore.suppression("datastore.tbldirect_optin", 1, "", "0000-00-00 00:00:00") ;
	call datastore.suppression("datastore.tbldirect_optin", 1, "", "0000-00-00 00:00:00", 1, 1) ;


-- 	ADDITION


--	textusave
	SET @aff_rows = 0 ;
        SELECT @prior_count := count(*) from datastore.tblmaster ;
        SELECT @records := count(*) from datastore.tbldirect_optin where source not like "leads.contact_forms%" and source not like "ecom.orders%" and source not like "ecom.customers%" and Status = 0 ;

	INSERT LOW_PRIORITY IGNORE INTO datastore.tblmaster 
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
		,county
		,region
		,zipcode
		,gender
		,companyname
		,jobtitle
		,industry
		,phonearea
		,phonenum
		,keywords
		,born
		,source
		,dtTimeStamp
		,dateadded
		,ip
		,domain
		,exclude
		,Confirmed
		,ConfirmedIP
		,ConfirmedTS
		,Opener
		,OpenerIP
		,OpenerTS
		,Clicker
		,ClickerIP
		,ClickerTS
		,country_short
	) 
	SELECT 
		listid
		,email
		,email_hash
		,firstname
		,middlename
		,lastname
		,address
		,address2
		,city
		,county
		,region
		,zipcode
		,gender
		,companyname
		,jobtitle
		,industry
		,phonearea
		,phonenum
		,keywords
		,born
		,source
		,dtTimeStamp
		,dateadded
		,ip
		,domain
		,exclude
		,Confirmed
		,ConfirmedIP
		,ConfirmedTS
		,Opener
		,OpenerIP
		,OpenerTS
		,Clicker
		,ClickerIP
		,ClickerTS
		,country_short 
	FROM datastore.tbldirect_optin WHERE source NOT LIKE "leads.contact_forms%" AND source NOT LIKE "ecom.orders%" AND source NOT LIKE "ecom.customers%" AND Status = 0  ; 

        SET @description = "textusave" ;
        SELECT @post_count := count(*) FROM datastore.tblmaster ;
        SELECT @aff_rows := @post_count - @prior_count  ;
        INSERT INTO datastore.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "textusave", @records, @aff_rows, @prior_count, @post_count, @description) ;

-- 	leads.contcact_forms
	SET @aff_rows = 0 ;
        SELECT @prior_count := count(*) from datastore.tblmaster ;
        SELECT @records := count(*) from datastore.tbldirect_optin where source like "leads.contact_forms%" and Status = 0 ;

	INSERT low_priority ignore into datastore.tblmaster 
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
	,county
	,region
	,zipcode
	,gender
	,companyname
	,jobtitle
	,industry
	,phonearea
	,phonenum
	,keywords
	,born
	,source
	,dtTimeStamp
	,dateadded
	,ip
	,domain
	,exclude
	,Confirmed
	,ConfirmedIP
	,ConfirmedTS
	,Opener
	,OpenerIP
	,OpenerTS
	,Clicker
	,ClickerIP
	,ClickerTS
	,country_short
	) 
	select 
		listid
		,email
		,email_hash
		,firstname
		,middlename
		,lastname
		,address
		,address2
		,city
		,county
		,region
		,zipcode
		,gender
		,companyname
		,jobtitle
		,industry
		,phonearea
		,phonenum
		,keywords
		,born
		,source
		,dtTimeStamp
		,dateadded
		,ip
		,domain
		,exclude
		,Confirmed
		,ConfirmedIP
		,ConfirmedTS
		,Opener
		,OpenerIP
		,OpenerTS
		,Clicker
		,ClickerIP
		,ClickerTS
		,country_short 
	from datastore.tbldirect_optin where Status = 0 and source like "leads.contact_forms%" ; 

        SET @description = "contact_forms" ;
        SELECT @post_count := count(*) FROM datastore.tblmaster ;
        SELECT @aff_rows := @post_count - @prior_count ;
        INSERT INTO datastore.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "contact_forms", @records, @aff_rows, @prior_count, @post_count, @description) ;

-- 	ecom.customers
	SET @aff_rows = 0 ;
        SELECT @prior_count := count(*) from datastore.tblmaster ;
        SELECT @records := count(*) from datastore.tbldirect_optin where source like "ecom.customers%" and Status = 0 ;

	INSERT low_priority ignore into datastore.tblmaster 
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
	,county
	,region
	,zipcode
	,gender
	,companyname
	,jobtitle
	,industry
	,phonearea
	,phonenum
	,keywords
	,born
	,source
	,dtTimeStamp
	,dateadded
	,ip
	,domain
	,exclude
	,Confirmed
	,ConfirmedIP
	,ConfirmedTS
	,Opener
	,OpenerIP
	,OpenerTS
	,Clicker
	,ClickerIP
	,ClickerTS
	,country_short
	) 
	select 
		listid
		,email
		,email_hash
		,firstname
		,middlename
		,lastname
		,address
		,address2
		,city
		,county
		,region
		,zipcode
		,gender
		,companyname
		,jobtitle
		,industry
		,phonearea
		,phonenum
		,keywords
		,born
		,source
		,dtTimeStamp
		,dateadded
		,ip
		,domain
		,exclude
		,Confirmed
		,ConfirmedIP
		,ConfirmedTS
		,Opener
		,OpenerIP
		,OpenerTS
		,Clicker
		,ClickerIP
		,ClickerTS
		,country_short 
	from datastore.tbldirect_optin where Status = 0 and source like "ecom.customers%" ; 

        SET @description = "customers" ;
        SELECT @post_count := count(*) FROM datastore.tblmaster ;
        SELECT @aff_rows := @post_count - @prior_count ;
        INSERT INTO datastore.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "customers", @records, @aff_rows, @prior_count, @post_count, @description) ;

-- 	ecom.orders
	SET @aff_rows = 0 ;
        SELECT @prior_count := count(*) from datastore.tblmaster ;
        SELECT @records := count(*) from datastore.tbldirect_optin where source like "ecom.orders%" and Status = 0 ;

	INSERT low_priority ignore into datastore.tblmaster 
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
	,county
	,region
	,zipcode
	,gender
	,companyname
	,jobtitle
	,industry
	,phonearea
	,phonenum
	,keywords
	,born
	,source
	,dtTimeStamp
	,dateadded
	,ip
	,domain
	,exclude
	,Confirmed
	,ConfirmedIP
	,ConfirmedTS
	,Opener
	,OpenerIP
	,OpenerTS
	,Clicker
	,ClickerIP
	,ClickerTS
	,country_short
	) 
	select 
		listid
		,email
		,email_hash
		,firstname
		,middlename
		,lastname
		,address
		,address2
		,city
		,county
		,region
		,zipcode
		,gender
		,companyname
		,jobtitle
		,industry
		,phonearea
		,phonenum
		,keywords
		,born
		,source
		,dtTimeStamp
		,dateadded
		,ip
		,domain
		,exclude
		,Confirmed
		,ConfirmedIP
		,ConfirmedTS
		,Opener
		,OpenerIP
		,OpenerTS
		,Clicker
		,ClickerIP
		,ClickerTS
		,country_short 
	from datastore.tbldirect_optin where Status = 0 and source like "ecom.orders%" ; 

        SET @description = "orders" ;
        SELECT @post_count := count(*) FROM datastore.tblmaster ;
        SELECT @aff_rows := @post_count - @prior_count  ;
        INSERT INTO datastore.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "orders", @records, @aff_rows, @prior_count, @post_count, @description) ;

-- 	datastore.tblmaster
	SET @aff_rows = 0 ;
        SELECT @prior_count := count(*) from datastore.tblmaster ;
        SET @records := @prior_count ;
        SET @description = "tblmaster baseline" ;
        SET @post_count := @prior_count ;
        SET @aff_rows := 0 ;
        INSERT INTO datastore.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "tblmaster", @records, @aff_rows, @prior_count, @post_count, @description) ;





 	TRUNCATE datastore.tbldirect_optin ; 
END ;
~
delimiter ;
