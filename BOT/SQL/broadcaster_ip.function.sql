use emarketing ;
drop function if exists emarketing.broadcaster_ip ;

delimiter ~

CREATE DEFINER=`admin`@`localhost` FUNCTION `broadcaster_ip`(campaign_id INT(10)) RETURNS varchar(25) DETERMINISTIC
BEGIN
	declare dwan_ip varchar(50) default "" ;
	select group_concat(s.wan_ip separator ',') into dwan_ip from emarketing.campaigns as c inner join emarketing.profiles as p on c.profileid = p.id and c.id = campaign_id inner join system.server as s on p.broadcastserver = s.name ;
	RETURN dwan_ip ;
END  ;

~

delimiter ;

