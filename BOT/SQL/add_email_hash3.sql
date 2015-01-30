use datastore ;
drop procedure if exists add_email_hash_three ;
delimiter ~


CREATE PROCEDURE add_email_hash_three(IN fqtname varchar(100))
BEGIN
        DECLARE done INT DEFAULT 0 ;
        DECLARE acctid VARCHAR(100) DEFAULT SUBSTR(fqtname, 2, instr(fqtname,'.')-2) ;
	DECLARE tname VARCHAR(100) DEFAULT SUBSTR(fqtname, instr(fqtname,'.')+1) ;

	SET @fqtname = fqtname ;
	SET @acctid = acctid ;
	SET @tname = tname ;

	SELECT TABLE_NAME, GROUP_CONCAT(COLUMN_NAME SEPARATOR ',') AS tcols INTO @table_name, @cols
		FROM information_schema.COLUMNS 
		WHERE TABLE_SCHEMA = CONCAT("d",acctid) 
		AND TABLE_NAME = tname ;


        REPEAT
		
		SET @indexname = "" ;
		SET @colname = "" ;
		SET @idinstring = 0 + INSTR(@cols,"id") ;
		SET @email_hashinstring = 0 + INSTR(@cols,"email_hash") ;
	

		IF @idinstring < 1
		THEN
			SET @idnot = "true" ;
			SELECT  INDEX_NAME, COLUMN_NAME INTO @indexname, @colname FROM information_schema.STATISTICS WHERE TABLE_NAME = @table_name AND INDEX_NAME = "PRIMARY" AND TABLE_SCHEMA = CONCAT("d",acctid) ;
			IF "" != @colname
			THEN
				SET @dropstring = CONCAT("ALTER TABLE ", @fqtname, " DROP PRIMARY KEY ");
				PREPARE dropstatement FROM @dropstring ;
				EXECUTE dropstatement ;
				DEALLOCATE PREPARE dropstatement ;

				SET @idsqlstring = CONCAT("ALTER TABLE ", @fqtname, " ADD COLUMN id INT(10) AUTO_INCREMENT PRIMARY KEY");
				PREPARE idstatement FROM @idsqlstring ;
				EXECUTE idstatement ;
				DEALLOCATE PREPARE idstatement ;
			ELSE
				SET @idsqlstring = CONCAT("ALTER TABLE ", @fqtname, " ADD COLUMN id INT(10) AUTO_INCREMENT PRIMARY KEY");
				PREPARE idstatement FROM @idsqlstring ;
				EXECUTE idstatement ;
				DEALLOCATE PREPARE idstatement ;
			END IF ;
		ELSE
			set @idnot = "false" ;
			SELECT  INDEX_NAME, COLUMN_NAME INTO @indexname, @colname FROM information_schema.STATISTICS WHERE TABLE_NAME = @table_name AND INDEX_NAME = "PRIMARY" AND TABLE_SCHEMA = CONCAT("d",acctid) ;

			IF  "" = @colname
			THEN
				SET @idstring = CONCAT("ALTER TABLE ", @fqtname, " ADD primary key (id) ") ;
				PREPARE idstatement FROM @idstring ;
				EXECUTE idstatement ;
				DEALLOCATE PREPARE idstatement ;
			ELSEIF "id" != @colname
			THEN
				
				SET @dropstring = CONCAT("ALTER TABLE ", @fqtname, " DROP PRIMARY KEY ");
				PREPARE dropstatement FROM @dropstring ;
				EXECUTE dropstatement ;
				DEALLOCATE PREPARE dropstatement ;

				SET @idstring = CONCAT("ALTER TABLE ", @fqtname, " ADD primary key (id) ") ;
				PREPARE astatement FROM @sqlstring4 ;
				EXECUTE astatement ;
				DEALLOCATE PREPARE astatement ;
			END IF ;
		END IF ;

		IF @email_hashinstring < 1
		THEN
			SET @hashstring = CONCAT("ALTER TABLE ", @fqtname, " ADD COLUMN email_hash BIGINT(17) UNSIGNED ZEROFILL ");
			PREPARE hashstatement FROM @hashstring ;
			EXECUTE hashstatement ;
			DEALLOCATE PREPARE hashstatement ;

			SET @updatestring = CONCAT("UPDATE ", @fqtname, " SET email_hash = CONV(SUBSTR(MD5(LOWER(`email`)),19,32),16,10)") ;
			PREPARE updatestatement FROM @updatestring ;
			EXECUTE updatestatement ;
			DEALLOCATE PREPARE updatestatement ;

			SET @indexstring = CONCAT("CREATE UNIQUE INDEX email_hash ON ", @fqtname, " (email_hash) ");
			PREPARE indexstatement FROM @indexstring ;
			EXECUTE indexstatement ;
			DEALLOCATE PREPARE indexstatement ;
		ELSE
			SELECT  INDEX_NAME, COLUMN_NAME INTO @indexname, @colname FROM information_schema.STATISTICS WHERE TABLE_NAME = @table_name AND INDEX_NAME = "email_hash" AND TABLE_SCHEMA = CONCAT("d",acctid) ;
			IF "email_hash" != @indexname
			THEN
				SET @updatestring = CONCAT("UPDATE ", @fqtname, " SET email_hash = CONV(SUBSTR(MD5(LOWER(`email`)),19,32),16,10) where email_hash = 0") ;
				PREPARE updatestatement FROM @updatestring ;
				EXECUTE updatestatement ;
				DEALLOCATE PREPARE updatestatement ;

				SET @indexstring = CONCAT("CREATE UNIQUE INDEX email_hash ON ", @fqtname, " (email_hash) ");
				PREPARE indexstatement FROM @indexstring ;
				EXECUTE indexstatement ;
				DEALLOCATE PREPARE indexstatement ;
			END IF ;
		END IF ;

		IF "unsubscribe" = @table_name
		THEN
			SET done = 1 ;
		ELSE
			SET @fqtname =   CONCAT("d",acctid,".","unsubscribe");
			SET @table_name = "" ;
			SET @cols = "" ;
			SELECT TABLE_NAME, GROUP_CONCAT(COLUMN_NAME SEPARATOR ',') AS tcols INTO @table_name, @cols
			FROM information_schema.COLUMNS 
			WHERE TABLE_SCHEMA = CONCAT("d",acctid) 
			AND TABLE_NAME =  "unsubscribe" ;
			
			SET @unsub_alter_string = CONCAT("alter table d",@acctid,".unsubscribe change column tsAdded tsAdded timestamp default current_timestamp ") ;
			PREPARE unsub_alter_statement FROM @unsub_alter_string ;
			EXECUTE unsub_alter_statement ;
			DEALLOCATE PREPARE unsub_alter_statement ;
		END IF ;

	        UNTIL 1 = done
        END REPEAT ;

END
~

delimiter ;



