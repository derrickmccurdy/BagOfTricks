
use datastore ;
drop procedure if exists rebuild_unsubscribe ;
delimiter ~
CREATE PROCEDURE rebuild_unsubscribe(IN acctid int)
BEGIN
        DECLARE done INT DEFAULT 0 ;
	DECLARE fqtname varchar(100) DEFAULT "" ;
	DECLARE cur1 CURSOR FOR SELECT  CONCAT(TABLE_SCHEMA,'.', TABLE_NAME ) AS FQtableName FROM information_schema.TABLES WHERE TABLE_SCHEMA = CONCAT("d",acctid)  AND 1 = TABLE_NAME regexp "^t[0-9]+" ;

        OPEN cur1 ;

        REPEAT
                FETCH cur1 INTO  fqtname ;
		
		SET @acctid = acctid ;
		SET @fqtname = fqtname ;
	
		IF "" != @fqtname
		THEN 

			SET @insert_string = CONCAT("insert ignore into d",@acctid, ".unsubscribe (email, email_hash) select email, conv(substr(md5(lower(`email`)),19,32),16,10)  from ", @fqtname, " where Status = 174") ;
--  (email, email_hash) into d", @acctid , ".unsubscribe select email, conv(substr(md5(lower(`email`)),19,32),16,10)  from ", @fqtname, " where Status = 174" ) ;
			PREPARE insert_statement FROM @insert_string ;
			EXECUTE insert_statement ;
			DEALLOCATE PREPARE insert_statement ;
		ELSE
			SET done = 1 ;
		END IF ;

	        UNTIL 1 = done
        END REPEAT ;
        CLOSE cur1 ;
	
END
~

delimiter ;

