use system ;
drop event if exists individual_fill_email_hash ;
delimiter ~


CREATE EVENT individual_fill_email_hash ON SCHEDULE EVERY 1 HOUR STARTS '2009-03-12 10:12:00' ON COMPLETION NOT PRESERVE DISABLE ON SLAVE 
COMMENT 'This event fills email_hash of system.tblglobal_individual' 
DO 
	BEGIN
		update system.tblglobal_individual set email_hash = conv(substr(md5(lower(`email`)),19,32),16,10) where email_hash = 0  or email_hash is null or email_hash = "" ;
	END ;

~

delimiter ;
