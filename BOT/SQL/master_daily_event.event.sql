use datastore ;
drop event if exists master_daily_event ;
delimiter ~

CREATE EVENT `master_daily_event` ON SCHEDULE EVERY 1 DAY STARTS '2009-03-19 01:12:00' ON COMPLETION PRESERVE ENABLE COMMENT 'add, remove and report on records in datastore.tblmaster' DO BEGIN
        call datastore.master_daily_event() ;
END ;

~

drop procedure if exists master_daily_event ~

CREATE  PROCEDURE master_daily_event()
BEGIN

        SET @aff_rows := 0 ;
        SET @prior_count := 0 ;
        SET @records := 0 ;
        SET @post_count := 0 ;
        
	insert into datastore.sproc (step) values ("beginning of master_daily_event") ;
        SELECT count(*) into @prior_count from datastore.tblmaster ;
        SELECT count(*) into @records  from system.tblglobal_individual ;
-- 	this is unnecessary as there is a trigger on system.tblglobal_individual which ensures the email_hash will never be 0 or null
--        UPDATE system.tblglobal_individual set email_hash = datastore.email_hash(email) where email_hash = 0 or email_hash is null ;

-- unsubscribes
--        REPLACE  INTO system.tblglobal_individual (listid, email, email_hash, firstname, middlename, lastname, address, address2, city, county, region, zipcode, gender, companyname, jobtitle, industry, phonearea, phonenum, keywords, born, source, dtTimeStamp, dateadded, ip, domain, exclude, Confirmed, ConfirmedIP, ConfirmedTS, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS, country_short, Status) select master.listid, master.email, master.email_hash, master.firstname, master.middlename, master.lastname, master.address, master.address2, master.city, master.county, master.region, master.zipcode, master.gender, master.companyname, master.jobtitle, master.industry, master.phonearea, master.phonenum, master.keywords, master.born, master.source, master.dtTimeStamp, master.dateadded, master.ip, master.domain, master.exclude, master.Confirmed, master.ConfirmedIP, master.ConfirmedTS, master.Opener, master.OpenerIP, master.OpenerTS, master.Clicker, master.ClickerIP, master.ClickerTS, master.country_short, 173 from datastore.tblmaster as master inner join system.tblglobal_individual as individuals on individuals.email_hash = master.email_hash where individuals.Status = 173 ;
        REPLACE  INTO system.tblglobal_suppressed_full (listid, email, email_hash, firstname, middlename, lastname, address, address2, city, county, region, zipcode, gender, companyname, jobtitle, industry, phonearea, phonenum, keywords, born, source, dtTimeStamp, dateadded, ip, domain, exclude, Confirmed, ConfirmedIP, ConfirmedTS, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS, country_short, Status) select master.listid, master.email, master.email_hash, master.firstname, master.middlename, master.lastname, master.address, master.address2, master.city, master.county, master.region, master.zipcode, master.gender, master.companyname, master.jobtitle, master.industry, master.phonearea, master.phonenum, master.keywords, master.born, master.source, master.dtTimeStamp, master.dateadded, master.ip, master.domain, master.exclude, master.Confirmed, master.ConfirmedIP, master.ConfirmedTS, master.Opener, master.OpenerIP, master.OpenerTS, master.Clicker, master.ClickerIP, master.ClickerTS, master.country_short, 173 from datastore.tblmaster as master inner join system.tblglobal_individual as individuals on individuals.email_hash = master.email_hash where individuals.Status = 173 ;


	insert into datastore.sproc (step) values ("master_daily_event 32") ;
--        DELETE datastore.tblmaster as master from datastore.tblmaster as master inner join system.tblglobal_individual as individual on individual.email_hash = master.email_hash where individual.Status = 173 ;
        DELETE datastore.tblmaster as master from datastore.tblmaster as master inner join system.tblglobal_suppressed as suppressed on suppressed.email_hash = master.email_hash where suppressed.Status = 173 ;

	insert into datastore.sproc (step) values ("master_daily_event 36") ;
        SET @description := "individual_suppression" ;
        SELECT count(*) into @post_count  FROM datastore.tblmaster ;
        SELECT @prior_count - @post_count into @aff_rows ;
        INSERT INTO datastore.record_reports (dateadded, table_name,records,affected_rows,prior_count, post_count,description) values(now(), "tblglobal_individual", @records, @aff_rows, @prior_count, @post_count, @description) ;

	insert into datastore.sproc (step) values ("master_daily_event 42") ;

-- domain suppression
        SET @aff_rows := 0 ;
        SELECT count(*) into @prior_count from datastore.tblmaster ;
        SELECT count(*) into @records from system.tblglobal_domains ;

        SELECT group_concat(domain_name separator ";") from system.tblglobal_domains where DATE_FORMAT(tsAdded,'%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),'%Y-%m-%d')  into @domain_wildcards ;

        IF @domain_wildcards IS NOT NULL
        THEN

	insert into datastore.sproc (step) values ("master_daily_event 54") ;
                SET @domain_retention_string2 := CONCAT("INSERT INTO system.tblglobal_suppressed_full (listid, email, email_hash, firstname, middlename, lastname, address, address2, city, county, region, zipcode, gender, companyname, jobtitle, industry, phonearea, phonenum, keywords, born, source, dtTimeStamp, dateadded, ip, domain, exclude, Confirmed, ConfirmedIP, ConfirmedTS, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS, country_short, Status) select master.listid, master.email, master.email_hash, master.firstname, master.middlename, master.lastname, master.address, master.address2, master.city, master.county, master.region, master.zipcode, master.gender, master.companyname, master.jobtitle, master.industry, master.phonearea, master.phonenum, master.keywords, master.born, master.source, master.dtTimeStamp, master.dateadded, master.ip, master.domain, master.exclude, master.Confirmed, master.ConfirmedIP, master.ConfirmedTS, master.Opener, master.OpenerIP, master.OpenerTS, master.Clicker, master.ClickerIP, master.ClickerTS, master.country_short, 171 from datastore.tblmaster as master where (email like \"%", REPLACE(@domain_wildcards, ";", "\" or email like \"%"), "\" ) ON DUPLICATE KEY UPDATE listid = master.listid, firstname = master.firstname, middlename = master.middlename, lastname = master.lastname, address = master.address, address2 = master.address2, city = master.city, county = master.county, region = master.region, zipcode = master.zipcode, gender = master.gender, companyname = master.companyname, jobtitle = master.jobtitle, industry = master.industry, phonearea = master.phonearea, phonenum = master.phonenum, keywords = master.keywords, born = master.born, source = master.source, dtTimeStamp = master.dtTimeStamp, dateadded = master.dateadded, ip = master.ip, domain = master.domain, exclude = master.exclude, Confirmed = master.Confirmed, ConfirmedIP = master.ConfirmedIP, ConfirmedTS = master.ConfirmedTS, Opener = master.Opener, OpenerIP = master.OpenerIP, OpenerTS = master.OpenerTS, Clicker = master.Clicker, ClickerIP = master.ClickerIP, ClickerTS = master.ClickerTS, country_short = master.country_short, Status = 171" ) ;
                PREPARE domain_retention_statement2 FROM @domain_retention_string2 ;
                EXECUTE domain_retention_statement2 ;
                DEALLOCATE PREPARE domain_retention_statement2 ;
	insert into datastore.sproc (step) values ("master_daily_event 59") ;

                SET @domain_string2 := CONCAT("DELETE FROM datastore.tblmaster where (email like \"%", REPLACE(@domain_wildcards, ";", "\" or email like \"%"), "\" )" ) ;
                PREPARE domain_statement2 FROM @domain_string2 ;
                EXECUTE domain_statement2 ;
                DEALLOCATE PREPARE domain_statement2 ;

	insert into datastore.sproc (step) values ("master_daily_event 66") ;
        END IF ;

        SET @description := "domain_suppression" ;
        SELECT count(*) into @post_count FROM datastore.tblmaster ;
        SELECT @prior_count - @post_count into @aff_rows ;
        INSERT INTO datastore.record_reports (dateadded, table_name,records,affected_rows,prior_count, post_count,description) values(now(), "tblglobal_domains", @records, @aff_rows, @prior_count, @post_count, @description) ;

	insert into datastore.sproc (step) values ("master_daily_event completed domain suppression operations ") ;

-- role suppression
        SET @aff_rows := 0 ;
        SELECT count(*) into @prior_count from datastore.tblmaster ;
        SELECT count(*) into @records from system.tblglobal_role ;

        SELECT group_concat(role_name separator ";") from system.tblglobal_role where DATE_FORMAT(tsAdded, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(current_date(), INTERVAL 1 DAY), '%Y-%m-%d')  into @roles ;

        IF @roles IS NOT NULL
        THEN

                SET @role_retention_string := CONCAT("INSERT INTO system.tblglobal_suppressed_full (listid, email, email_hash, firstname, middlename, lastname, address, address2, city, county, region, zipcode, gender, companyname, jobtitle, industry, phonearea, phonenum, keywords, born, source, dtTimeStamp, dateadded, ip, domain, exclude, Confirmed, ConfirmedIP, ConfirmedTS, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS, country_short, Status) select master.listid, master.email, master.email_hash, master.firstname, master.middlename, master.lastname, master.address, master.address2, master.city, master.county, master.region, master.zipcode, master.gender, master.companyname, master.jobtitle, master.industry, master.phonearea, master.phonenum, master.keywords, master.born, master.source, master.dtTimeStamp, master.dateadded, master.ip, master.domain, master.exclude, master.Confirmed, master.ConfirmedIP, master.ConfirmedTS, master.Opener, master.OpenerIP, master.OpenerTS, master.Clicker, master.ClickerIP, master.ClickerTS, master.country_short, 172 from datastore.tblmaster as master where (email like \"%", REPLACE(@roles, ";", "\" or email like \"%"), "\" ) ON DUPLICATE KEY UPDATE listid = master.listid, firstname = master.firstname, middlename=master.middlename, lastname = master.lastname, address = master.address, address2 = master.address2, city= master.city, county = master.county, region = master.region, zipcode = master.zipcode, gender = master.gender , companyname = master.companyname, jobtitle = master.jobtitle, industry = master.industry, phonearea = master.phonearea, phonenum = master.phonenum, keywords = master.keywords, born = master.born, source = master.source, dtTimeStamp = master.dtTimeStamp, dateadded = master.dateadded, ip = master.ip, domain = master.domain, exclude = master.exclude, Confirmed = master.Confirmed, ConfirmedIP = master.ConfirmedIP, ConfirmedTS = master.ConfirmedTS, Opener = master.Opener, OpenerIP = master.OpenerIP, OpenerTS = master.OpenerTS, Clicker = master.Clicker, ClickerIP = master.ClickerIP, ClickerTS = master.ClickerTS, country_short = master.country_short, Status = 172" ) ;
                PREPARE role_retention_statement FROM @role_retenton_string ;
                EXECUTE role_retention_statement ;
                DEALLOCATE PREPARE role_retention_statement ;

                SET @role_string := CONCAT("DELETE FROM datastore.tblmaster where (email like \"%", REPLACE(@roles, ";", "\" or email like \"%"), "\" )" ) ;
                PREPARE role_statement FROM @role_string ;
                EXECUTE role_statement ;
                DEALLOCATE PREPARE role_statement ;

        END IF ;

        SET @description := "role_suppression" ;
        SELECT count(*) into @post_count FROM datastore.tblmaster ;
        SELECT @prior_count - @post_count into @aff_rows ;
        INSERT INTO datastore.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "tblglobal_role", @records, @aff_rows, @prior_count, @post_count, @description) ;


	insert into datastore.sproc (step) values ("master_daily_event completed role suppression operations ") ;

-- bounce suppression 86,87
        SET @aff_rows := 0 ;
        SELECT count(*) into @prior_count from datastore.tblmaster ;
        SELECT count(*) into @records  from system.tblglobal_suppressed_full ;


--        REPLACE  INTO system.tblglobal_suppressed_full (listid, email, email_hash, firstname, middlename, lastname, address, address2, city, county, region, zipcode, gender, companyname, jobtitle, industry, phonearea, phonenum, keywords, born, source, dtTimeStamp, dateadded, ip, domain, exclude, Confirmed, ConfirmedIP, ConfirmedTS, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS, country_short, Status) select master.listid, master.email, master.email_hash, master.firstname, master.middlename, master.lastname, master.address, master.address2, master.city, master.county, master.region, master.zipcode, master.gender, master.companyname, master.jobtitle, master.industry, master.phonearea, master.phonenum, master.keywords, master.born, master.source, master.dtTimeStamp, master.dateadded, master.ip, master.domain, master.exclude, master.Confirmed, master.ConfirmedIP, master.ConfirmedTS, master.Opener, master.OpenerIP, master.OpenerTS, master.Clicker, master.ClickerIP, master.ClickerTS, master.country_short, bounces.Status from datastore.tblmaster as master inner join datastore.tblbounces as bounces on bounces.email_hash = master.email_hash where bounces.email_hash <> 0  and bounces.Status in(86,87) and DATE_FORMAT(date_added, '%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d')  ; 
        REPLACE  INTO system.tblglobal_suppressed_full (listid, email, email_hash, firstname, middlename, lastname, address, address2, city, county, region, zipcode, gender, companyname, jobtitle, industry, phonearea, phonenum, keywords, born, source, dtTimeStamp, dateadded, ip, domain, exclude, Confirmed, ConfirmedIP, ConfirmedTS, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS, country_short, Status) select master.listid, master.email, master.email_hash, master.firstname, master.middlename, master.lastname, master.address, master.address2, master.city, master.county, master.region, master.zipcode, master.gender, master.companyname, master.jobtitle, master.industry, master.phonearea, master.phonenum, master.keywords, master.born, master.source, master.dtTimeStamp, master.dateadded, master.ip, master.domain, master.exclude, master.Confirmed, master.ConfirmedIP, master.ConfirmedTS, master.Opener, master.OpenerIP, master.OpenerTS, master.Clicker, master.ClickerIP, master.ClickerTS, master.country_short, bounces.Status from datastore.tblmaster as master inner join system.tblglobal_bounces_report as bounces on bounces.email_hash = master.email_hash where bounces.email_hash <> 0  and bounces.Status in(86,87) and DATE_FORMAT(bounces.date_added, '%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d')  ; 


-- FIXME put precompile bounce report statements here
	insert into datastore.out_report (tsadded, AccountID , campaign_id , dcount) select date_added, custid as AccountID, campaign_id, count(email_hash) as dcount from system.tblglobal_bounces_report where Status in(86,87) and date_format(date_added, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d')  group by campaign_id order by count(email_hash) desc ;
	insert into datastore.out_report (tsadded, AccountID, campaign_id, dcount) select dateadded, "individual suppressed" as AccountID, email as campaign_id, 1 as dcount from system.tblglobal_suppressed_full where Status = 173 and date_format(tsadded, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d') ;
	insert into datastore.out_report (tsadded, AccountID, campaign_id, dcount) select dateadded, "role suppressed" as AccountID, "" as campaign_id, count(email_hash) as dcount from system.tblglobal_suppressed_full where Status = 172 and date_format(tsadded, '%Y-%m-%d')  = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d') ;
	insert into datastore.out_report (tsadded, AccountID, campaign_id, dcount) select dateadded, "domain suppressed" as AccountID, "" as campaign_id, count(email_hash) as dcount from system.tblglobal_suppressed_full where Status = 171 and date_format(tsadded, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d') ; 


--        DELETE datastore.tblmaster as master from datastore.tblmaster as master inner join datastore.tblbounces as bounces  on bounces.email_hash = master.email_hash where bounces.Status in(86,87) and DATE_FORMAT(date_added, '%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d')  ; 
        DELETE datastore.tblmaster as master from datastore.tblmaster as master inner join system.tblglobal_bounces_report as bounces  on bounces.email_hash = master.email_hash where bounces.Status in(86,87) and DATE_FORMAT(bounces.date_added, '%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d')  ; 

        SET @description := "bounce_suppression" ;
        SELECT count(*) into @post_count  FROM datastore.tblmaster ;
        SELECT @prior_count - @post_count into @aff_rows ;
        INSERT INTO datastore.record_reports (dateadded, table_name,records,affected_rows,prior_count, post_count,description) values(now(), "tblbounces", @records, @aff_rows, @prior_count, @post_count, @description) ;

	insert into datastore.sproc (step) values ("master_daily_event completed bounce suppression operations ") ;






        
-- direct optins
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
                        ,datastore.email_hash(email)
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
                FROM leads.contact_forms WHERE DATE_FORMAT(DateTime, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 21 DAY), '%Y-%m-%d') ;


	insert into datastore.sproc (step) values ("master_daily_event completed contact_forms insert ") ;

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
                                ,datastore.email_hash(email)
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
                        FROM ecom.customers WHERE DATE_FORMAT(TimeAdded,'%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 21 DAY), '%Y-%m-%d') ;

	insert into datastore.sproc (step) values ("master_daily_event completed ecom.customers insert ") ;


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
                                ,datastore.email_hash(BillEmail)
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
                        FROM ecom.orders where DATE_FORMAT(TimeOrdered, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 21 DAY), '%Y-%m-%d') ;


	insert into datastore.sproc (step) values ("master_daily_event completed ecom.orders insert ") ;
        
	call datastore.remove_dups_2("datastore.tbldirect_optin") ;
--        call datastore.suppression("datastore.tbldirect_optin", 1, "", "0000-00-00 00:00:00") ;
        call datastore.suppression("datastore.tbldirect_optin", 1, "", "0000-00-00 00:00:00", 1, 1) ;


	insert into datastore.sproc (step) values ("master_daily_event completed direct_optin suppression ") ;



	insert into datastore.sproc (step) values ("master_daily_event starting tbldirect_optin addition operations ") ;


        SET @aff_rows := 0 ;
        SELECT count(*) into @prior_count from datastore.tblmaster ;
        SELECT count(*) into @records  from datastore.tbldirect_optin where source not like "leads.contact_forms%" and source not like "ecom.orders%" and source not like "ecom.customers%" and Status = 0 ;

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

        SET @description := "textusave" ;
        SELECT count(*) into @post_count  FROM datastore.tblmaster ;
        SELECT @post_count - @prior_count into @aff_rows ;
        INSERT INTO datastore.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "textusave", @records, @aff_rows, @prior_count, @post_count, @description) ;


        SET @aff_rows := 0 ;
        SELECT count(*) into @prior_count from datastore.tblmaster ;
        SELECT count(*) into @records from datastore.tbldirect_optin where source like "leads.contact_forms%" and Status = 0 ;

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

        SET @description := "contact_forms" ;
        SELECT count(*) into @post_count FROM datastore.tblmaster ;
        SELECT @post_count - @prior_count into @aff_rows ;
        INSERT INTO datastore.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "contact_forms", @records, @aff_rows, @prior_count, @post_count, @description) ;


        SET @aff_rows := 0 ;
        SELECT count(*) into @prior_count from datastore.tblmaster ;
        SELECT count(*) into @records from datastore.tbldirect_optin where source like "ecom.customers%" and Status = 0 ;

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

        SET @description := "customers" ;
        SELECT count(*) into @post_count FROM datastore.tblmaster ;
        SELECT @post_count - @prior_count into @aff_rows ;
        INSERT INTO datastore.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "customers", @records, @aff_rows, @prior_count, @post_count, @description) ;


        SET @aff_rows := 0 ;
        SELECT count(*) into @prior_count from datastore.tblmaster ;
        SELECT count(*) into @records from datastore.tbldirect_optin where source like "ecom.orders%" and Status = 0 ;

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

        SET @description := "orders" ;
        SELECT count(*) into @post_count FROM datastore.tblmaster ;
        SELECT @post_count - @prior_count into @aff_rows ;
        INSERT INTO datastore.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "orders", @records, @aff_rows, @prior_count, @post_count, @description) ;


        SET @aff_rows := 0 ;
        SELECT count(*) into @prior_count from datastore.tblmaster ;
        SET @records := @prior_count ;
        SET @description := "tblmaster baseline" ;
        SET @post_count := @prior_count ;
        INSERT INTO datastore.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "tblmaster", @records, @aff_rows, @prior_count, @post_count, @description) ;

        TRUNCATE datastore.tbldirect_optin ; 
	insert into datastore.sproc (step) values ("end of master_daily_event") ;
END ;

~

delimiter ;
