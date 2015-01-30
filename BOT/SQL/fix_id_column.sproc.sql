use datastore ;
drop procedure if exists fix_id ;
delimiter ~


create procedure fix_id(IN fqtname varchar(100))
begin

	set @fqtname = fqtname ;

	SET @idsqlstring = CONCAT("ALTER TABLE ", @fqtname, " change column id client_id varchar(100)");
	PREPARE idstatement FROM @idsqlstring ;
	EXECUTE idstatement ;
	DEALLOCATE PREPARE idstatement ;

	SET @idsqlstring = CONCAT("ALTER TABLE ", @fqtname, " ADD COLUMN id INT(10) AUTO_INCREMENT PRIMARY KEY");
	PREPARE idstatement FROM @idsqlstring ;
	EXECUTE idstatement ;
	DEALLOCATE PREPARE idstatement ;

	SET @idsqlstring = CONCAT("ALTER TABLE ", @fqtname, " add column email_hash bigint(20)");
	PREPARE idstatement FROM @idsqlstring ;
	EXECUTE idstatement ;
	DEALLOCATE PREPARE idstatement ;

	SET @idsqlstring = CONCAT("update ", @fqtname, " set email_hash = conv(substr(md5(lower(email)),19,32),16,10)");
	PREPARE idstatement FROM @idsqlstring ;
	EXECUTE idstatement ;
	DEALLOCATE PREPARE idstatement ;

	SET @idsqlstring = CONCAT("ALTER TABLE ", @fqtname, " change column email_hash email_hash bigint zerofill unique ");
	PREPARE idstatement FROM @idsqlstring ;
	EXECUTE idstatement ;
	DEALLOCATE PREPARE idstatement ;

end ;
~
delimiter ;

