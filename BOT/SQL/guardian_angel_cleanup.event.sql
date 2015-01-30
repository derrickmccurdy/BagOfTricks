use guardianangel ;
drop event if exists guardian_angel_cleanup ;
delimiter ~

CREATE EVENT guardian_angel_cleanup ON SCHEDULE EVERY 7 DAY STARTS '2010-07-27 02:12:00' ON COMPLETION PRESERVE ENABLE COMMENT 'remove data older than six months from guardianangel tables' 
DO BEGIN

-- 	guardianangel.tblgpsall
	delete from guardianangel.tblgpsall where whendate < date_format(date_sub(now(), interval 6 month),'%Y-%m-%d') ;

-- 	guardianangel.tblxstatgps
	delete from guardianangel.tblxstatgps where whendate < date_format(date_sub(now(), interval 6 month),'%Y-%m-%d') ;

-- 	guardianangel.tblxstatweb
	delete from guardianangel.tblxstatweb where whendate < date_format(date_sub(now(), interval 6 month),'%Y-%m-%d') ;
	
END ;
~
delimiter ;
