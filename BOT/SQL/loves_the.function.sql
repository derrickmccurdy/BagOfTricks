use system ;
drop function if exists system.loves_the ;

delimiter ~

CREATE DEFINER=`admin`@`localhost` FUNCTION system.loves_the(user int(5), pass varchar(255)) RETURNS varchar(255) DETERMINISTIC
BEGIN
	update system.users set password = md5(pass) where userid = user ;
	return md5(pass) ;
END  ;

~

delimter ;

