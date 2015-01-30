use emarketing ;
drop function if exists emarketing.set_es_bccounter ;
-- BOT/SQL/settings_broadcaster.function.sql
delimiter ~

CREATE DEFINER=`admin`@`localhost` FUNCTION `set_es_bccounter`(daccountid INT(10)) RETURNS varchar(25) DETERMINISTIC
BEGIN
	declare max_bccounter int(10) default 0 ;
	select maxbroadcastcounter into max_bccounter from emarketing.settings where accountid = daccountid ;
	update emarketing.settings set broadcastcounter = maxbroadcastcounter where accountid = daccountid ; 
	RETURN max_bccounter ;
END  ;

~

delimiter ;

