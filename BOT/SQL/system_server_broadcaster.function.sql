use emarketing ;
drop function if exists emarketing.set_ss_bccounter ;
-- BOT/SQL/settings_broadcaster.function.sql
delimiter ~

CREATE DEFINER=`admin`@`localhost` FUNCTION `set_ss_bccounter`(dcampaign_id INT(10)) RETURNS int(10) DETERMINISTIC
BEGIN
	declare max_bccounter int(10) default 0 ;
	select s.maxbroadcastcounter into max_bccounter from emarketing.campaigns as c inner join emarketing.profiles as p on c.profileid = p.id and c.id = dcampaign_id inner join system.server as s on p.broadcastserver = s.name and s.removed = 0 ;
	update emarketing.campaigns as c inner join emarketing.profiles as p on c.profileid = p.id and c.id = dcampaign_id inner join system.server as s on p.broadcastserver = s.name and s.removed = 0 set s.broadcastcounter = s.maxbroadcastcounter  ;
	RETURN max_bccounter ;
END  ;

~

delimiter ;

