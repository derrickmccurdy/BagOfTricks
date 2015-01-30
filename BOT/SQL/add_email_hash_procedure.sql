CREATE  PROCEDURE datastore.add_email_hash(IN AccountID INT)
BEGIN
        DECLARE done INT DEFAULT 0 ;
        DECLARE fqtname VARCHAR(100) DEFAULT "" ;
        DECLARE tname VARCHAR(100) DEFAULT "" ;
        DECLARE cur1 CURSOR FOR SELECT TABLE_NAME, CONCAT(TABLE_SCHEMA,'.', TABLE_NAME ) AS FQtableName FROM information_schema.TABLES WHERE TABLE_SCHEMA = CONCAT("d",AccountID) AND 1 = TABLE_NAME REGEXP 'unsubscribe|^t[0-9]+.*|^s[0-9]+.*'  ;
        OPEN cur1 ;

        REPEAT
                FETCH cur1 INTO  tname, fqtname ;
                SET @tname = tname ;
                SET @fqtname = fqtname ;
                SET @iname = "aaaa" ;
                IF "" != @fqtname
                THEN
			IF "unsubscribe" != @tname
			THEN
				SET @remove_dups_string = CONCAT("CALL datastore.remove_dups('", @fqtname, "')") ;
				PREPARE remove_statement FROM @remove_dups_string ;
				EXECUTE remove_statement ;
				DEALLOCATE PREPARE remove_statement ;
			END IF ;

                        SELECT  INDEX_NAME INTO @iname FROM information_schema.STATISTICS WHERE TABLE_NAME = @tname AND INDEX_NAME = "email_hash" ;
                        IF "email_hash" != @iname
                        THEN

                                SET @sqlstring1 = CONCAT("ALTER TABLE ", @fqtname, " ADD COLUMN email_hash BIGINT(17) UNSIGNED ZEROFILL ") ;
                                PREPARE astatement FROM @sqlstring1 ;
                                EXECUTE astatement ;
                                DEALLOCATE PREPARE astatement ;
                                SET @sqlstring2 = concat("UPDATE ", @fqtname, " SET email_hash = CONV(SUBSTR(MD5(LOWER(`email`)),19,32),16,10)") ;
                                PREPARE ustatement FROM @sqlstring2 ;
                                EXECUTE ustatement ;
                                DEALLOCATE PREPARE ustatement ;

                                SET @sqlstring4 = CONCAT("ALTER TABLE ", @fqtname, " ADD INDEX email_hash (email_hash) ") ;
                                PREPARE astatement FROM @sqlstring4 ;
                                EXECUTE astatement ;
                                DEALLOCATE PREPARE astatement ;

                        END IF ;
                ELSE
                        SET done = 1 ;
                END IF ;
        UNTIL 1 = done
        END REPEAT ;
        CLOSE cur1 ;
END 
