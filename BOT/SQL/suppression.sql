use datastore ;
drop procedure if exists suppression ;
drop procedure if exists test_suppression ;
delimiter ~
-- CREATE PROCEDURE test_suppression(IN fqtname varchar(100), ROLES tinyint(1), DOMAIN_INCLUDE varchar(200), SUPPRESSION_TIME datetime)
-- CREATE PROCEDURE suppression(IN fqtname varchar(100), ROLES tinyint(1), DOMAIN_INCLUDE varchar(200), SUPPRESSION_TIME datetime)
CREATE PROCEDURE suppression(IN fqtname varchar(100), ROLES tinyint(1), DOMAIN_INCLUDE varchar(200), SUPPRESSION_TIME datetime, INDIVIDUAL tinyint(1), DOMAINS tinyint(1))
BEGIN
        DECLARE done INT DEFAULT 0 ;
        DECLARE acctid VARCHAR(100) DEFAULT SUBSTR(fqtname, 2, instr(fqtname,'.')-2) ;
	DECLARE tname VARCHAR(100) DEFAULT SUBSTR(fqtname, instr(fqtname,'.')+1) ;

	SET @fqtname := fqtname ;
	SET @acctid := acctid ;
	SET @tname := tname ;
	SET @ROLES := ROLES ;
	SET @INDIVIDUALS := INDIVIDUAL ;
	SET @DOMAINS := DOMAINS ;
	SET @SUPPRESSION_TIME := SUPPRESSION_TIME ;
	SET @DOMAIN_INCLUDE := DOMAIN_INCLUDE ;


	IF "0000-00-00 00:00:00" <> @SUPPRESSION_TIME
	THEN
		SET @domain_time_string := CONCAT(" where g.tsAdded > \"",@SUPPRESSION_TIME,"\" ") ;
		SET @domain_wildcard_time_string := CONCAT(" AND tsAdded > \"",@SUPPRESSION_TIME,"\" ") ;
	ELSE
		SET @domain_time_string := CONCAT(" where g.tsAdded > \"0000-00-00 00:00:00\" ") ;
		SET @domain_wildcard_time_string := CONCAT(" AND tsAdded > \"0000-00-00 00:00:00\" ") ;
	END IF ;


	IF "" <> @DOMAIN_INCLUDE
	THEN
		SET @domain_include_string := CONCAT(" and g.domain_name not like \"", REPLACE(@DOMAIN_INCLUDE, ";", "\" and g.domain_name not like \""), "\"") ;
		SET @domain_include_string2 := CONCAT(" and ( domain not like \"", REPLACE(@DOMAIN_INCLUDE, ";", "\" and domain not like \""), "\" )") ;
	ELSE
		SET @domain_include_string := "" ;
		SET @domain_include_string2 := "" ;
	END IF ;

-- domain suppression
	SET @domain_fill_string := CONCAT("UPDATE ", @fqtname,  " set domain = SUBSTR(email, instr(email,'@')+1)  where domain  = '' or domain is null") ;
	PREPARE domain_fill_statement FROM @domain_fill_string ;
	EXECUTE domain_fill_statement ;
	DEALLOCATE PREPARE domain_fill_statement ;

	IF 1 = @DOMAINS
	THEN
		SET @domain_string := CONCAT("UPDATE ", @fqtname,  " AS t inner join system.tblglobal_domains  as g on t.domain = g.domain_name SET t.Status = 171 ", @domain_time_string, @domain_include_string) ;
		PREPARE domain_statement FROM @domain_string ;
		EXECUTE domain_statement ;
		DEALLOCATE PREPARE domain_statement ;
		
		select sleep(1) into @dsleep ;
		SET @timestamp := rand(unix_timestamp()) ;
		SET @domain_outfile_string := concat("SELECT domain_name into outfile '/tmp/d",@acctid,"_",@timestamp,"wild.txt' FIELDS TERMINATED by ';' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED by '' from system.tblglobal_domains where domain_name like \"%\%%\" ", @domain_wildcard_time_string) ;
		PREPARE outfile_statement from @domain_outfile_string ;
		EXECUTE outfile_statement ;
		DEALLOCATE PREPARE outfile_statement ;


		SET @domain_wildcards := "" ;

		set @d_wildcards_string := concat("set @domain_wildcards := load_file('/tmp/d",@acctid,"_",@timestamp,"wild.txt')" );
		PREPARE wildcards_statement from @d_wildcards_string ;
		EXECUTE wildcards_statement ;
		DEALLOCATE PREPARE wildcards_statement ;

		IF "" <> @domain_wildcards 
		THEN
-- 	-- 		get rid of %&#37\; winblows pasted in crap
			SET @domain_wildcards := REPLACE(@domain_wildcards, '%&#37\\;','%') ;
-- 	-- 		take the trailing ; off the @domain_wildcards string
			SET @domain_wildcards := SUBSTR(@domain_wildcards, 1, length(@domain_wildcards)-1) ;
			SET @unsub_domain_wildcard_string := CONCAT("update ",@fqtname, " set Status = 171 where  email like ", REPLACE(@domain_wildcards, ";", " or email like "),  @domain_include_string2 ) ;
			PREPARE unsub_wildcard_suppress_statement from @unsub_domain_wildcard_string ;
			EXECUTE unsub_wildcard_suppress_statement ;
			DEALLOCATE PREPARE unsub_wildcard_suppress_statement ;
		END IF ;
	END IF ;


-- individual suppression
	SET @individual_fill_string := CONCAT("UPDATE ", @fqtname, " set email_hash = conv(substr(md5(lower(`email`)),19,32),16,10) where email_hash = 0 OR email_hash is null") ;
	PREPARE individual_fill_statement FROM @individual_fill_string ;
	EXECUTE individual_fill_statement ;
	DEALLOCATE PREPARE individual_fill_statement ;

	IF 1 = @INDIVIDUALS
	THEN
		SET @individual_string := CONCAT("UPDATE ", @fqtname,  " AS t inner join system.tblglobal_individual  as g ON t.email_hash =  g.email_hash SET t.Status = 173 where g.email_hash <> 0 AND g.Status = 173 ") ;
		PREPARE individual_statement FROM @individual_string ;
		EXECUTE individual_statement ;
		DEALLOCATE PREPARE individual_statement ;
	END IF ;


-- role suppression
	IF 1 = @ROLES
	THEN
		IF "0000-00-00 00:00:" <> @SUPPRESSION_TIME
		THEN
			SELECT concat(" email like \"",replace((select group_concat(role_name) from system.tblglobal_role where tsAdded > @SUPPRESSION_TIME),',','" or email like "'),"\"") into @where_clause ;
		ELSE
			SELECT concat(" email like \"",replace((select group_concat(role_name) from system.tblglobal_role ),',','" or email like "'),"\"") into @where_clause ;
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


-- unsubscribe list suppression
	SET @unsub_fill_string := CONCAT("UPDATE d", @acctid, ".unsubscribe  set email_hash = conv(substr(md5(lower(`email`)),19,32),16,10) where unsubscribe.email_hash = 0 or unsubscribe.email_hash is null" ) ;
	PREPARE unsub_fill_statement FROM @unsub_fill_string ;
	EXECUTE unsub_fill_statement ;
	DEALLOCATE PREPARE unsub_fill_statement ;

	SET @unsub_string := CONCAT("UPDATE ", @fqtname,  " AS t inner join d", @acctid, ".unsubscribe as unsubscribe ON t.email_hash = unsubscribe.email_hash SET t.Status = 174 " ) ;
	PREPARE unsubstatement FROM @unsub_string ;
	EXECUTE unsubstatement ;
	DEALLOCATE PREPARE unsubstatement ;


	select sleep(1) into @dsleep ;
	SET @timestamp := rand(unix_timestamp()) ;
	SET @outfile_string := concat("SELECT email into outfile '/tmp/d",@acctid,"_",@timestamp,"wild.txt' FIELDS TERMINATED by ';' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED by '' from d",@acctid,".unsubscribe where email like \"%\%%\"") ;
	PREPARE outfile_statement from @outfile_string ;
	EXECUTE outfile_statement ;
	DEALLOCATE PREPARE outfile_statement ;


	SET @wildcards := "" ;

	set @wildcards_string := concat("set @wildcards := load_file('/tmp/d",@acctid,"_",@timestamp,"wild.txt')" );
	PREPARE wildcards_statement from @wildcards_string ;
	EXECUTE wildcards_statement ;
	DEALLOCATE PREPARE wildcards_statement ;

	IF "" <> @wildcards 
	THEN
-- 		get rid of %&#37\; winblows pasted in crap
		SET @wildcards := REPLACE(@wildcards, '%&#37\\;','%') ;
-- 		take the trailing ; off the @wildcards string
		SET @wildcards := SUBSTR(@wildcards, 1, length(@wildcards)-1) ;
		SET @unsub_wildcard_string := CONCAT("update ",@fqtname, " set Status = 174 where  email like ", REPLACE(@wildcards, ";", " or email like ")) ;
		PREPARE unsub_wildcard_suppress_statement from @unsub_wildcard_string ;
		EXECUTE unsub_wildcard_suppress_statement ;
		DEALLOCATE PREPARE unsub_wildcard_suppress_statement ;
	END IF ;


-- bounce suppression
/*
-- 	commented out due to performance issue
	SET @bounce_string := CONCAT("update ", @fqtname, " as client_table inner join datastore.tblbounces as bounces on client_table.email_hash = bounces.email_hash set client_table.Status = bounces.Status where  bounces.Status in(86,87)") ;
	PREPARE bounce_statement from @bounce_string ;
	EXECUTE bounce_statement ;
	DEALLOCATE PREPARE bounce_statement ;
*/
END
~

delimiter ;



