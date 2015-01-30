use datastore ;
drop function if exists datastore.email_hash ;

delimiter ~

CREATE DEFINER=`admin`@`localhost` FUNCTION `email_hash`(email_address VARCHAR(100)) RETURNS bigint(20) DETERMINISTIC
BEGIN
	RETURN CONV(SUBSTR(MD5(LOWER(email_address)),19,32),16,10) ;
END  ;

~

delimter ;

