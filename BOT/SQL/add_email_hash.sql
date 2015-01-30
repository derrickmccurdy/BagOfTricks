use datastore ;
delimiter ~


CREATE PROCEDURE `add_email_hash_2`(IN AccountID INT)
BEGIN
        DECLARE done INT DEFAULT 0 ;
        DECLARE fqtname VARCHAR(100) DEFAULT "" ;
        DECLARE tname VARCHAR(100) DEFAULT "" ;
        DECLARE cols VARCHAR(254) DEFAULT "" ;
--        DECLARE cur1 CURSOR FOR SELECT TABLE_NAME, CONCAT(TABLE_SCHEMA,'.', TABLE_NAME ) AS FQtableName FROM information_schema.TABLES WHERE TABLE_SCHEMA = CONCAT("d",AccountID) AND 1 = TABLE_NAME REGEXP 'unsubscribe|^t[0-9]+.*|^s[0-9]+.*'  ;
        DECLARE cur1 CURSOR FOR SELECT TABLE_NAME, CONCAT(TABLE_SCHEMA,'.', TABLE_NAME ) AS FQtableName,  group_concat(COLUMN_NAME separator ",") as tcols FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = CONCAT("d",AccountID) AND 1 = TABLE_NAME REGEXP 'unsubscribe|^t[0-9]+.*|^s[0-9]+.*' GROUP BY TABLE_NAME ;

        OPEN cur1 ;

        REPEAT
                FETCH cur1 INTO  tname, fqtname, cols ;
		
                SET @tname = tname ;
                SET @fqtname = fqtname ;
                SET @iname = "aaaa" ;
		SET @cols = cols ;

                IF "" != @fqtname
                THEN
			IF "id" NOT IN(@cols)
			THEN
	                        SET @idsqlstring = CONCAT("ALTER TABLE ", @fqtname, " ADD COLUMN id int(10) auto_increment ");
                                PREPARE idstatement FROM @idsqlstring ;
                                EXECUTE idstatement ;
                                DEALLOCATE PREPARE idstatement ;

				SELECT  INDEX_NAME INTO @indexname, COLUMN_NAME INTO @colname FROM information_schema.STATISTICS WHERE TABLE_NAME = @tname AND INDEX_NAME = "PRIMARY" ;
				IF "" != @colname
				THEN
					SET @dropstring = CONCAT("ALTER TABLE ", @fqtname, " DROP PRIMARY KEY ");
					PREPARE dropstatement FROM @dropstring ;
					EXECUTE dropstatement ;
					DEALLOCATE PREPARE dropstatement ;
				END IF ;

	                        SET @idkeystring = CONCAT("ALTER TABLE ", @fqtname, " ADD PRIMARY KEY (id) ");
                                PREPARE idkeystatement FROM @idkeystring ;
                                EXECUTE idkeystatement ;
                                DEALLOCATE PREPARE idkeystatement ;
			ELSE
				SELECT  INDEX_NAME INTO @indexname, COLUMN_NAME INTO @colname FROM information_schema.STATISTICS WHERE TABLE_NAME = @tname AND INDEX_NAME = "PRIMARY" ;

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

			IF "email_hash" NOT IN(@cols)
			THEN
                                SET @hashstring = CONCAT("ALTER TABLE ", @fqtname, " ADD COLUMN email_hash BIGINT(17) UNSIGNED ZEROFILL ");
                                PREPARE hashstatement FROM @hashstring ;
                                EXECUTE hashstatement ;
                                DEALLOCATE PREPARE hashstatement ;

                                SET @updatestring = CONCAT("UPDATE ", @fqtname, " SET email_hash = CONV(SUBSTR(MD5(LOWER(`email`)),19,32),16,10)") ;
                                PREPARE updatestatement FROM @updatestring ;
                                EXECUTE updatestatement ;
                                DEALLOCATE PREPARE updatestatement ;

                                SET @indexstring = CONCAT("ALTER TABLE ", @fqtname, " ADD INDEX email_hash (email_hash) UNIQUE ");
                                PREPARE indexstatement FROM @indexstring ;
                                EXECUTE indexstatement ;
                                DEALLOCATE PREPARE indexstatement ;
			ELSE
				SELECT  INDEX_NAME INTO @indexname, COLUMN_NAME INTO @colname FROM information_schema.STATISTICS WHERE TABLE_NAME = @tname AND INDEX_NAME = "email_hash" ;
				IF "email_hash" != @indexname
				THEN
					SET @updatestring = CONCAT("UPDATE ", @fqtname, " SET email_hash = CONV(SUBSTR(MD5(LOWER(`email`)),19,32),16,10) where email_hash = 0") ;
					PREPARE updatestatement FROM @updatestring ;
					EXECUTE updatestatement ;
					DEALLOCATE PREPARE updatestatement ;

					SET @indexstring = CONCAT("ALTER TABLE ", @fqtname, " ADD INDEX email_hash (email_hash) UNIQUE ");
					PREPARE indexstatement FROM @indexstring ;
					EXECUTE indexstatement ;
					DEALLOCATE PREPARE indexstatement ;
				END IF ;
			END IF ;
                ELSE
			SET done = 1 ;
                END IF ;
        UNTIL 1 = done
        END REPEAT ;
        CLOSE cur1 ;
END
~

delimiter ;



