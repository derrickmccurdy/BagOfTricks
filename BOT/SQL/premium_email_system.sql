/*
-- need interfaces for import, list_build, list_count
-- are we going to have a premium broadcaster?
-- do we need bounces, and individuals tables? I do not think so...
-- 	bounces maybe but definitely not individuals
*/


create database if not exists premium ;

-- premium.importarchive
create table if not exists premium.importarchive (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'default record id for this table',
  `AccountID` int(10) NOT NULL,
  `channelID` int(10) NOT NULL,
  `filename` varchar(255) NOT NULL COMMENT 'path and filename of gzipped original import file.',
  `importdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `keywords` varchar(255) NOT NULL COMMENT 'Put keywords related to the type of recipients imported',
  `description` varchar(255) NOT NULL COMMENT 'Please describe the contents of this file and the deficiency it is intended to address.',
  `initial_records` int(10) DEFAULT NULL,
  `imported_records` int(10) DEFAULT NULL,
  `address_format_fail` int(10) DEFAULT NULL,
  `bounce_fail` int(10) DEFAULT NULL,
  `individual_fail` int(10) DEFAULT NULL,
  `domain_fail` int(10) DEFAULT NULL,
  `role_fail` int(10) DEFAULT NULL,
  `lookup_fail` int(10) DEFAULT NULL,
  `self_duplicate_fail` int(10) NOT NULL,
  `redundant_fail` int(10) DEFAULT NULL,
  `dns_lookup_fail` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ;



-- premium.channels
create table if not exists premium.channels (
  id int(10) not null auto_increment primary key,
  channel varchar(150) not null,
  unique key channel (channel)
) ;

-- premium.interest
create table premium.interest ( id int(10) not null auto_increment, interest varchar(150) not null, primary key (id), unique key interest (interest) ) ;

-- premium.industry
create table premium.industry ( id int(10) not null auto_increment, industry varchar(150) not null, primary key (id), unique key industry (industry) ) ;

-- premium.premium_tmp
create table if not exists premium.premium_tmp (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`listid` int(10) DEFAULT NULL,
	`email` varchar(200) NOT NULL,
	`email_hash` bigint(17) unsigned zerofill ,
	`firstname` varchar(45) NOT NULL,
	`middlename` varchar(45) NOT NULL,
	`lastname` varchar(45) NOT NULL,
	`address` varchar(250) NOT NULL,
	`address2` varchar(250) NOT NULL,
	`city` varchar(95) NOT NULL,
	`region` varchar(25) NOT NULL,
	`zipcode` varchar(20) NOT NULL DEFAULT '0',
	`gender` varchar(5) NOT NULL,
	`companyname` varchar(45) NOT NULL,
	`jobtitle` varchar(45) NOT NULL,
	`industry` varchar(45) NOT NULL,
	`phonenum` varchar(15) NOT NULL,
	`keywords` varchar(250) DEFAULT NULL,
	`born` date NOT NULL DEFAULT '0000-00-00',
	`source` varchar(250) NOT NULL,
	`dtTimeStamp` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`ip` varchar(20) not null DEFAULT '0',
	`domain` varchar(100) DEFAULT NULL,
	`country_short` varchar(10) NOT NULL,
	`Status` varchar(30) NOT NULL default '3',
	PRIMARY KEY (`id`)
	) ;

	drop trigger if exists premium.before_premium_tmp_insert ;
                delimiter ~
                CREATE  TRIGGER premium.before_premium_tmp_insert before insert on premium.premium_tmp
                FOR EACH ROW
                BEGIN
                        set NEW.email_hash :=  datastore.email_hash(NEW.email) ;
                        set NEW.domain := substring(NEW.email,instr(NEW.email,'@')+1, length(NEW.email)) ;
                        SET NEW.keywords := concat(NEW.keywords, ' ', NEW.email, ' ', NEW.companyname, ' ', NEW.industry, ' ', NEW.jobtitle, ' ', NEW.source) ;
                        CASE WHEN NEW.Status  = "Address doesn't exist" THEN set NEW.Status := 86 WHEN NEW.Status = "Bad Syntax" THEN set NEW.Status := 87 WHEN NEW.Status = "Globally Suppressed - Domain" THEN SET NEW.Status := 171 WHEN NEW.Status = "Globally Suppressed - Role" THEN set NEW.Status := 172 WHEN NEW.Status  = "Globally Suppressed - Individual" THEN set NEW.Status := 173 WHEN NEW.Status = "Good" THEN set NEW.Status := 0 WHEN NEW.Status = "Timed Out" THEN set NEW.Status := 1 WHEN NEW.Status = "Blocked" THEN set NEW.Status := 2 WHEN NEW.Status = "Unknown Code" THEN set NEW.Status := 3 WHEN NEW.Status = "Server/Domain not found" THEN set NEW.Status := 85 ELSE set NEW.Status := 3 END ;
                END ;
                ~
                delimiter ;



-- premium.premium_test
-- 	needs a status col
-- 	trigger on this table to ensure proper value for domain
	CREATE TABLE if not exists premium.premium_test (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`listid` int(10) DEFAULT NULL,
	`email` varchar(200) NOT NULL,
	`email_hash` bigint(17) unsigned zerofill NOT NULL,
	`firstname` varchar(45) NOT NULL,
	`middlename` varchar(45) NOT NULL,
	`lastname` varchar(45) NOT NULL,
	`address` varchar(250) NOT NULL,
	`address2` varchar(250) NOT NULL,
	`city` varchar(95) NOT NULL,
	`region` varchar(25) NOT NULL,
	`zipcode` varchar(20) NOT NULL DEFAULT '0',
	`gender` varchar(5) NOT NULL,
	`companyname` varchar(45) NOT NULL,
	`jobtitle` varchar(45) NOT NULL,
	`industry` varchar(45) NOT NULL,
	`phonenum` varchar(15) NOT NULL,
	`keywords` varchar(250) DEFAULT NULL,
	`born` date NOT NULL DEFAULT '0000-00-00',
	`source` varchar(250) NOT NULL,
	`dtTimeStamp` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`ip` int(10) unsigned NOT NULL DEFAULT '0',
	`domain` varchar(100) DEFAULT NULL,
	`country_short` varchar(10) NOT NULL,
	`Status` tinyint(3) unsigned NOT NULL default '0',
	PRIMARY KEY (`id`),
	UNIQUE KEY `email_hash` (`email_hash`)
	) ;



-- premium.premium_email_holding
	CREATE TABLE if not exists premium.premium_email_holding (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`listid` int(10) DEFAULT NULL,
	`email` varchar(200) NOT NULL,
	`email_hash` bigint(17) unsigned zerofill NOT NULL,
	`firstname` varchar(45) NOT NULL,
	`middlename` varchar(45) NOT NULL,
	`lastname` varchar(45) NOT NULL,
	`address` varchar(250) NOT NULL,
	`address2` varchar(250) NOT NULL,
	`city` varchar(95) NOT NULL,
	`region` varchar(25) NOT NULL,
	`zipcode` varchar(20) NOT NULL DEFAULT '0',
	`gender` varchar(5) NOT NULL,
	`companyname` varchar(45) NOT NULL,
	`jobtitle` varchar(45) NOT NULL,
	`industry` varchar(45) NOT NULL,
	`phonenum` varchar(15) NOT NULL,
	`keywords` varchar(250) DEFAULT NULL,
	`born` date NOT NULL DEFAULT '0000-00-00',
	`source` varchar(250) NOT NULL,
	`dtTimeStamp` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`sent_to_date` date NOT NULL DEFAULT '0000-00-00',
	`ip` int(10) unsigned NOT NULL DEFAULT '0',
	`domain` varchar(100) DEFAULT NULL,
	`country_short` varchar(10) NOT NULL,
	`Status` tinyint(3) unsigned NOT NULL default '0',
	PRIMARY KEY (`id`),
	UNIQUE KEY `email_hash` (`email_hash`),
	KEY `company` (`companyname`),
	KEY `region` (`region`),
	KEY `zip` (`zipcode`),
	KEY `keywords` (`keywords`),
	KEY `country` (`country_short`),
	KEY `Status` (`Status`)
	) ;
-- 	triggers into premium.premium_email
		drop trigger if exists premium.after_premium_email_holding_update ;
		delimiter ~
		CREATE  TRIGGER premium.after_premium_email_holding_update after update on premium.premium_email_holding
		FOR EACH ROW
		BEGIN
			IF NEW.Status < 85
			THEN
				IF NEW.sent_to_date <> '0000-00-00'
				THEN
					insert into premium.premium_email (listid,email,email_hash,firstname,middlename,lastname,address,address2,city,region,zipcode,gender,companyname,jobtitle,industry,phonenum,keywords,born,source,dtTimeStamp,ip,domain,country_short) select listid,email,email_hash,firstname,middlename,lastname,address,address2,city,region,zipcode,gender,companyname,jobtitle,industry,phonenum,keywords,born,source,dtTimeStamp,ip,domain,country_short from premium.premium_email_holding where email_hash = NEW.email_hash ;
					delete from  premium.premium_email_holding where email_hash = NEW.email_hash ;
				END IF ;
			END IF ;
		END ;
		~
		delimiter ;






-- premium.premium_email
	CREATE TABLE if not exists premium.premium_email (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`listid` int(10) DEFAULT NULL,
	`email` varchar(200) NOT NULL,
	`email_hash` bigint(17) unsigned zerofill NOT NULL,
	`firstname` varchar(45) NOT NULL,
	`middlename` varchar(45) NOT NULL,
	`lastname` varchar(45) NOT NULL,
	`address` varchar(250) NOT NULL,
	`address2` varchar(250) NOT NULL,
	`city` varchar(95) NOT NULL,
	`region` varchar(25) NOT NULL,
	`zipcode` varchar(20) NOT NULL DEFAULT '0',
	`gender` varchar(5) NOT NULL,
	`companyname` varchar(45) NOT NULL,
	`jobtitle` varchar(45) NOT NULL,
	`industry` varchar(45) NOT NULL,
	`phonenum` varchar(15) NOT NULL,
	`keywords` varchar(250) DEFAULT NULL,
	`born` date NOT NULL DEFAULT '0000-00-00',
	`source` varchar(250) NOT NULL,
	`dtTimeStamp` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`ip` int(10) unsigned NOT NULL DEFAULT '0',
	`domain` varchar(100) DEFAULT NULL,
	`country_short` varchar(10) NOT NULL,
	PRIMARY KEY (`id`),
	UNIQUE KEY `email_hash` (`email_hash`),
	KEY `company` (`companyname`),
	KEY `region` (`region`),
	KEY `zip` (`zipcode`),
	KEY `keywords` (`keywords`),
	KEY `country` (`country_short`)
	) ;



-- premium.bounces
	CREATE TABLE if not exists premium.bounces (
	`id` int(10) NOT NULL AUTO_INCREMENT,
	`AccountID` int(10) NOT NULL,
	`email` varchar(255) NOT NULL,
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`Status` tinyint(3) unsigned NOT NULL DEFAULT '0',
	`email_hash` bigint(17) unsigned zerofill NOT NULL,
	`campaign_id` int(10) DEFAULT NULL,
	PRIMARY KEY (`id`),
	KEY `status` (`Status`),
	KEY `dateadded` (`dateadded`),
	KEY `email_hash` (`email_hash`),
	KEY `campaign_id` (`campaign_id`)
	) ;

--	triggers into premium.suppressed
--	triggers into premium.bounces_operate
		drop trigger if exists premium.before_bounces_insert ;
		delimiter ~
		CREATE  TRIGGER premium.before_bounces_insert before insert on premium.bounces
		FOR EACH ROW
		BEGIN
			set NEW.email_hash :=  datastore.email_hash(NEW.email) ;
		END ;
		~
		delimiter ;

		drop trigger if exists premium.after_bounce_insert ;
		delimiter ~
		CREATE TRIGGER premium.after_bounce_insert after insert on premium.bounces
		FOR EACH ROW
		BEGIN
			IF  NEW.Status > 85
			THEN
				insert ignore into premium.suppressed (email_hash, Status) values(NEW.email_hash, NEW.Status) ;
				insert ignore into premium.bounces_operate (AccountID, email, Status, email_hash, campaign_id) values(NEW.AccountID, NEW.email, NEW.Status, NEW.email_hash, NEW.campaign_id) ;
			END IF ;
		END ;
		~
		delimiter ;



-- premium.bounces_operate
	CREATE TABLE if not exists premium.bounces_operate (
	`id` int(10) NOT NULL AUTO_INCREMENT,
	`AccountID` int(10) NOT NULL,
	`email` varchar(255) NOT NULL,
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`Status` tinyint(3) unsigned NOT NULL DEFAULT '0',
	`email_hash` bigint(17) unsigned zerofill NOT NULL,
	`campaign_id` int(10) DEFAULT NULL,
	PRIMARY KEY (`id`),
	KEY `status` (`Status`),
	KEY `dateadded` (`dateadded`),
	UNIQUE KEY `email_hash` (`email_hash`),
	KEY `campaign_id` (`campaign_id`)
	) ;



-- premium.suppressed_domains
	CREATE TABLE if not exists premium.suppressed_domains (
	`domain_name` char(255) DEFAULT NULL,
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	UNIQUE KEY `glbl_domains` (`domain_name`)
	) ;


-- premium.suppressed_roles
	CREATE TABLE if not exists premium.suppressed_roles (
	`role_name` char(255) DEFAULT NULL,
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	UNIQUE KEY `glbl_role` (`role_name`),
	KEY dateadded (dateadded)
	) ;



-- WE DO NOT NEED THIS TABLE
-- premium.suppressed_individuals
-- 	triggers into premium.suppressed



-- premium.suppressed
	CREATE TABLE if not exists premium.suppressed (
	`id` int(10) NOT NULL AUTO_INCREMENT,
	`email_hash` bigint(17) unsigned zerofill DEFAULT NULL,
	`Status` tinyint(3) unsigned NOT NULL DEFAULT '173',
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	UNIQUE KEY `email_hash` (`email_hash`),
	KEY `dateadded` (`dateadded`),
	KEY `Status` (`Status`)
	) ;

--	triggers into premium.suppressed_full
--	triggers into premium.suppressed_operate
		drop trigger if exists premium.after_suppressed_insert ;
		delimiter ~
		CREATE TRIGGER premium.after_suppressed_insert after insert on premium.suppressed
		FOR EACH ROW
		BEGIN
			insert ignore into premium.suppressed_operate (email_hash, Status) values(NEW.email_hash, NEW.Status) ;
			insert ignore into premium.suppressed_full (email_hash, Status) values(NEW.email_hash, NEW.Status) ;
		END ;
		~
		delimiter ;
	




-- premium.suppressed_full
	CREATE TABLE if not exists premium.suppressed_full (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`listid` int(10) DEFAULT NULL,
	`email` varchar(200) NOT NULL,
	`email_hash` bigint(17) unsigned zerofill NOT NULL,
	`Status` tinyint(3) unsigned NOT NULL,
	`firstname` varchar(45) NOT NULL,
	`middlename` varchar(45) NOT NULL,
	`lastname` varchar(45) NOT NULL,
	`address` varchar(250) NOT NULL,
	`address2` varchar(250) NOT NULL,
	`city` varchar(95) NOT NULL,
	`region` varchar(25) NOT NULL,
	`zipcode` varchar(20) NOT NULL DEFAULT '0',
	`gender` varchar(5) NOT NULL,
	`companyname` varchar(45) NOT NULL,
	`jobtitle` varchar(45) NOT NULL,
	`industry` varchar(45) NOT NULL,
	`phonenum` varchar(15) NOT NULL,
	`keywords` varchar(250) DEFAULT NULL,
	`born` date NOT NULL DEFAULT '0000-00-00',
	`source` varchar(250) NOT NULL,
	`dtTimeStamp` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
	`dateadded` timestamp NOT NULL DEFAULT current_timestamp,
	`ip` int(10) unsigned NOT NULL DEFAULT '0',
	`domain` varchar(100) DEFAULT NULL,
	`country_short` varchar(10) NOT NULL,
	PRIMARY KEY (`id`),
	UNIQUE KEY `email_hash` (`email_hash`),
	KEY dateadded (dateadded),
	KEY `Status` (`Status`)
	) ;
--	triggers out of premium.premium_email
		drop trigger if exists premium.after_suppressed_full_insert ;
		delimiter ~
		CREATE TRIGGER premium.after_suppressed_full_insert after insert on premium.suppressed_full
		FOR EACH ROW
		BEGIN
			update premium.suppressed_full as full inner join premium.premium_email as email on full.email_hash = email.email_hash set full.listid = email.listid, full.email = email.email, full.firstname = email.firstname, full.middlename = email.middlename, full.lastname = email.lastname, full.address = email.address, full.address2 = email.address2, full.city = email.city, full.region = email.region, full.zipcode = email.zipcode, full.gender = email.gender, full.companyname = email.companyname, full.jobtitle = email.jobtitle, full.industry = email.industry , full.phonenum = email.phonenum , full.keywords = email.keywords, full.born = email.born , full.source = email.source, full.dtTimeStamp = email.dtTimeStamp, full.dateadded = email.dateadded, full.ip = email.ip, full.domain = email.domain, full.country_short = email.country_short where email.email_hash = NEW.email_hash limit 1 ;
			delete from premium.premium_email where email_hash = NEW.email_hash limit 1 ;
		END ;
		~
		delimiter ;



-- premium.suppressed_operate
	CREATE TABLE if not exists premium.suppressed_operate (
	`id` int(10) NOT NULL AUTO_INCREMENT,
	`email_hash` bigint(17) unsigned zerofill DEFAULT NULL,
	`Status` tinyint(3) unsigned NOT NULL DEFAULT '173',
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	UNIQUE KEY `email_hash` (`email_hash`),
	KEY `dateadded` (`dateadded`),
	KEY `Status` (`Status`)
	) ;





-- premium.record_reports
	CREATE TABLE if not exists premium.record_reports (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`table_name` varchar(50) NOT NULL,
	`records` int(11) NOT NULL,
	`affected_rows` int(10) DEFAULT NULL,
	`prior_count` int(10) DEFAULT NULL,
	`post_count` int(10) DEFAULT NULL,
	`description` varchar(250) DEFAULT NULL,
	`archive_id` int(10) DEFAULT NULL,
	PRIMARY KEY (`id`),
	KEY dateadded (dateadded)
	) ;

-- premium.holding_record_reports
	CREATE TABLE if not exists premium.holding_record_reports (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`table_name` varchar(50) NOT NULL,
	`records` int(11) NOT NULL,
	`affected_rows` int(10) DEFAULT NULL,
	`prior_count` int(10) DEFAULT NULL,
	`post_count` int(10) DEFAULT NULL,
	`description` varchar(250) DEFAULT NULL,
	`archive_id` int(10) DEFAULT NULL,
	PRIMARY KEY (`id`),
	KEY dateadded (dateadded)
	) ;




-- premium.out_report
	CREATE TABLE if not exists premium.out_report (
	`id` int(10) NOT NULL AUTO_INCREMENT,
	`AccountID` varchar(100) DEFAULT NULL,
	`campaign_id` varchar(100) DEFAULT NULL,
	`dcount` int(10) DEFAULT NULL,
	`dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	KEY dateadded (dateadded)
	) ;




-- premium.suppression
--  	stored procedure premium.suppression suppresses client table against against premium.suppressed which contains all previously suppressed addresses. No records should be allowed into premium.premium_email that match any role, domain, individual or bounced records
	drop procedure if exists premium.suppression;
        delimiter ~
        CREATE  PROCEDURE premium.suppression(IN fqtname varchar(100), ROLES tinyint(1), SUPPRESSION_TIME datetime)
        BEGIN
		DECLARE done INT DEFAULT 0 ;
		DECLARE acctid VARCHAR(100) DEFAULT SUBSTR(fqtname, 2, instr(fqtname,'.')-2) ;
		DECLARE tname VARCHAR(100) DEFAULT SUBSTR(fqtname, instr(fqtname,'.')+1) ;

		SET @fqtname := fqtname ;
		SET @acctid := acctid ;
		SET @tname := tname ;
		SET @ROLES := ROLES ;
		SET @SUPPRESSION_TIME := SUPPRESSION_TIME ;


		IF "0000-00-00 00:00:00" <> @SUPPRESSION_TIME
		THEN
			SET @domain_time_string := CONCAT(" where g.dateadded > \"",@SUPPRESSION_TIME,"\" ") ;
			SET @domain_wildcard_time_string := CONCAT(" AND dateadded > \"",@SUPPRESSION_TIME,"\" ") ;
		ELSE
			SET @domain_time_string := CONCAT(" where g.dateadded > \"0000-00-00 00:00:00\" ") ;
			SET @domain_wildcard_time_string := CONCAT(" AND dateadded > \"0000-00-00 00:00:00\" ") ;
		END IF ;

		SET @domain_fill_string := CONCAT("UPDATE ", @fqtname,  " set domain = SUBSTR(email, instr(email,'@')+1)  where domain  = '' or domain is null") ;
		PREPARE domain_fill_statement FROM @domain_fill_string ;
		EXECUTE domain_fill_statement ;
		DEALLOCATE PREPARE domain_fill_statement ;

		SET @domain_string := CONCAT("UPDATE ", @fqtname,  " AS t inner join premium.suppressed_domains  as g on t.domain = g.domain_name SET t.Status = 171 ", @domain_time_string) ;
		PREPARE domain_statement FROM @domain_string ;
		EXECUTE domain_statement ;
		DEALLOCATE PREPARE domain_statement ;

		SET @wild_card_domain_string  := CONCAT("SELECT group_concat(domain_name separator \";\") from premium.suppressed_domains where domain_name like \"%\%%\" ", @domain_wildcard_time_string, " into @domain_wildcards") ;
		PREPARE domain_wild_statement from @wild_card_domain_string ;
		EXECUTE domain_wild_statement ;
		DEALLOCATE PREPARE domain_wild_statement ;

		IF @domain_wildcards IS NOT NULL
		THEN
			SET @domain_string2 := CONCAT("UPDATE ", @fqtname,  "  SET Status = 171 where (email like \"", REPLACE(@domain_wildcards, ";", "\" or email like \""), "\" )" ) ;
			PREPARE domain_statement2 FROM @domain_string2 ;
			EXECUTE domain_statement2 ;
			DEALLOCATE PREPARE domain_statement2 ;

		END IF ;

		SET @individual_fill_string := CONCAT("UPDATE ", @fqtname, " set email_hash = conv(substr(md5(lower(`email`)),19,32),16,10) where email_hash = 0 OR email_hash is null") ;
		PREPARE individual_fill_statement FROM @individual_fill_string ;
		EXECUTE individual_fill_statement ;
		DEALLOCATE PREPARE individual_fill_statement ;

		SET @individual_string := CONCAT("UPDATE ", @fqtname,  " AS t inner join premium.suppressed  as g ON t.email_hash =  g.email_hash SET t.Status = 173 where g.email_hash <> 0 AND g.Status = 173 ") ;
		PREPARE individual_statement FROM @individual_string ;
		EXECUTE individual_statement ;
		DEALLOCATE PREPARE individual_statement ;

		IF 1 = @ROLES
		THEN
			IF "0000-00-00 00:00:" <> @SUPPRESSION_TIME
			THEN
				SELECT concat(" email like \"",replace((select group_concat(role_name) from premium.suppressed_roles where dateadded > @SUPPRESSION_TIME),',','" or email like "'),"\"") into @where_clause ;
			ELSE
				SELECT concat(" email like \"",replace((select group_concat(role_name) from premium.suppressed_roles ),',','" or email like "'),"\"") into @where_clause ;
			END IF ;
		ELSE
			SET @where_clause := " email like \"abuse@%\" ";
		END IF ;

		IF @where_clause IS NULL
		THEN
			SET @where_clause := " email like \"abuse@%\" ";
		END IF ;



		SET @role_string := CONCAT("update ", @fqtname, " set Status = 172 where ", @where_clause) ;
		PREPARE role_statement from @role_string ;
		EXECUTE role_statement ;
		DEALLOCATE PREPARE role_statement ;


		set @unsub_table_error_triggered := 0 ;
		BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '42S02'
			BEGIN
				SET @unsub_table_error_triggered := 1 ;
			END ;

			SET @unsub_fill_string := CONCAT("UPDATE d", @acctid, ".unsubscribe  set email_hash = conv(substr(md5(lower(`email`)),19,32),16,10) where unsubscribe.email_hash = 0 or unsubscribe.email_hash is null" ) ;
			PREPARE unsub_fill_statement FROM @unsub_fill_string ;
			IF 0 = @unsub_table_error_triggered 
			THEN
				EXECUTE unsub_fill_statement ;
				DEALLOCATE PREPARE unsub_fill_statement ;

				SET @unsub_string := CONCAT("UPDATE ", @fqtname,  " AS t inner join d", @acctid, ".unsubscribe as unsubscribe ON t.email_hash = unsubscribe.email_hash SET t.Status = 174 " ) ;
				PREPARE unsubstatement FROM @unsub_string ;
				EXECUTE unsubstatement ;
				DEALLOCATE PREPARE unsubstatement ;


				SET @unsub_wildcard_select := CONCAT("SELECT group_concat(email separator \";\") from d",@acctid,".unsubscribe where email like \"%\%%\" into @wildcards") ;
				PREPARE unsub_wild_statement from @unsub_wildcard_select ;
				EXECUTE unsub_wild_statement ;
				DEALLOCATE PREPARE unsub_wild_statement ;
				
				IF "" <> @wildcards 
				THEN
					SET @unsub_wildcard_string := CONCAT("update ",@fqtname, " set Status = 174 where  email like \"", REPLACE(@wildcards, ";", "\" or email like \""), "\"") ;
					PREPARE unsub_wildcard_suppress_statement from @unsub_wildcard_string ;
					EXECUTE unsub_wildcard_suppress_statement ;
					DEALLOCATE PREPARE unsub_wildcard_suppress_statement ;
				END IF ;
			END IF ;
		END ;

	END ;
	~
	delimiter ;


-- premium.premium_daily_event
-- 	event that calls stored procedure named premium.premium_daily_event
-- 	premium.premium_daily_event stored procedure runs suppression on premium.premium_email against premium.suppressed_domains
-- 	premium.premium_daily_event stored procedure runs suppression on premium.premium_email against premium.suppressed_roles
-- 	premium.premium_daily_event stored procedure populates premium.record_reports
-- 	premium.premium_daily_event stored procedure populates premium.out_report
-- 	premium.premium_daily_event stored procedure truncates premium.bounces and premium.bounces_operate
	drop event if exists premium.premium_daily_event ;
	delimiter ~
	CREATE EVENT premium.premium_daily_event ON SCHEDULE EVERY 1 DAY STARTS '2009-03-19 01:12:00' ON COMPLETION PRESERVE ENABLE COMMENT 'add, remove and report on records in premium.premium_email' DO BEGIN
		call premium.premium_daily_event() ;
	END ;
	~
	delimiter ;

	drop procedure if exists premium.premium_daily_event ;
	delimiter ~
	CREATE  PROCEDURE premium.premium_daily_event()
	BEGIN
		SET @aff_rows := 0 ;
		SET @prior_count := 0 ;
		SET @records := 0 ;
		SET @post_count := 0 ;
		
		insert into datastore.sproc (step) values ("beginning of premium_daily_event") ;
-- unsubscribes 173
		insert into premium.record_reports (table_name, affected_rows,  description) select "screamers", count(email_hash), "individual_suppression" from premium.suppressed where Status = 173 and date_format(dateadded, '%Y-%m-%d') = date_format(date_sub(current_date(), interval 1 day), '%Y-%m-%d') ;
		insert into datastore.sproc (step) values ("premium_daily_event 173 done") ;

-- domain suppression 171
		SET @aff_rows := 0 ;
		SET @domain_wildcards := NULL ;

		SELECT count(*) into @prior_count from premium.premium_email;

		SELECT group_concat(domain_name separator ";") from premium.suppressed_domains where DATE_FORMAT(dateadded,'%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),'%Y-%m-%d')  into @domain_wildcards ;

		IF @domain_wildcards IS NOT NULL
		THEN

			SET @domain_retention_string2 := CONCAT("INSERT INTO premium.suppressed (email_hash, Status) select email_hash, 171 from premium.premium_email where (email like \"%", REPLACE(@domain_wildcards, ";", "\" or email like \"%"), "\" ) " ) ;
			PREPARE domain_retention_statement2 FROM @domain_retention_string2 ;
			EXECUTE domain_retention_statement2 ;
			DEALLOCATE PREPARE domain_retention_statement2 ;
		END IF ;

		SET @description := "domain_suppression" ;
		SELECT count(*) into @post_count FROM premium.premium_email;
		SELECT @prior_count - @post_count into @aff_rows ;
		INSERT INTO premium.record_reports (table_name,records,affected_rows,prior_count, post_count,description) values("suppressed_domains", @records, @aff_rows, @prior_count, @post_count, @description) ;

		insert into datastore.sproc (step) values ("master_daily_event completed domain suppression operations ") ;

-- role suppression 172
		SET @aff_rows := 0 ;
		SELECT count(*) into @prior_count from premium.premium_email ;
		SELECT count(*) into @records from premium.suppressed_roles ;
		SET @roles := NULL ;

		SELECT group_concat(role_name separator ";") from premium.suppressed_roles where DATE_FORMAT(dateadded, '%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(current_date(), INTERVAL 1 DAY), '%Y-%m-%d')  into @roles ;

		IF @roles IS NOT NULL
		THEN
			SET @role_retention_string := CONCAT("INSERT INTO premium.suppressed (email_hash, Status) select email_hash, 172 from premium.premium_email where (email like \"%", REPLACE(@roles, ";", "\" or email like \"%"), "\" ) " ) ;
			PREPARE role_retention_statement FROM @role_retenton_string ;
			EXECUTE role_retention_statement ;
			DEALLOCATE PREPARE role_retention_statement ;
		END IF ;

		SET @description := "role_suppression" ;
		SELECT count(*) into @post_count FROM premium.premium_email ;
		SELECT @prior_count - @post_count into @aff_rows ;
		INSERT INTO premium.record_reports (dateadded, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "suppressed_roles", @records, @aff_rows, @prior_count, @post_count, @description) ;


		insert into datastore.sproc (step) values ("master_daily_event completed role suppression operations ") ;

-- bounce suppression 86,87
		SET @aff_rows := 0 ;
		SELECT count(*) into @prior_count from premium.premium_email ;
		SELECT count(*) into @records  from premium.suppressed ;

	-- FIXME put precompile bounce report statements here
		insert into premium.out_report (dateadded, AccountID, campaign_id , dcount) select dateadded, AccountID, campaign_id, count(email_hash) as dcount from premium.bounces_operate where Status in(86,87) and date_format(dateadded, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d')  group by campaign_id order by count(email_hash) desc ;
		insert into premium.out_report (dateadded, AccountID, campaign_id, dcount) select dateadded, "individual suppressed" as AccountID, email as campaign_id, 1 as dcount from premium.suppressed_full where Status = 173 and date_format(dateadded, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d') ;
		insert into premium.out_report (dateadded, AccountID, campaign_id, dcount) select dateadded, "role suppressed" as AccountID, "" as campaign_id, count(email_hash) as dcount from premium.suppressed_full where Status = 172 and date_format(dateadded, '%Y-%m-%d')  = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d') ;
		insert into premium.out_report (dateadded, AccountID, campaign_id, dcount) select dateadded, "domain suppressed" as AccountID, domain as campaign_id, count(email_hash) as dcount from premium.suppressed_full where Status = 171 and date_format(dateadded, '%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d') ; 

		SET @description := "bounce_suppression" ;
		SELECT count(*) into @post_count  FROM premium.premium_email ;
		SELECT @prior_count - @post_count into @aff_rows ;
		INSERT INTO premium.record_reports (dateadded, table_name,records,affected_rows,prior_count, post_count,description) values(now(), "tblbounces", @records, @aff_rows, @prior_count, @post_count, @description) ;

		insert into datastore.sproc (step) values ("premium_daily_event completed ") ;
	END ;
	~
	delimiter ;



