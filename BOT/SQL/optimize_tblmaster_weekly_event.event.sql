use datastore ;
drop event if exists datastore.optimize_tblmaster_weekly_event ;
delimiter ~
CREATE EVENT datastore.optimize_tblmaster_weekly_event ON SCHEDULE EVERY 7 DAY STARTS '2009-06-21 12:12:00' ON COMPLETION PRESERVE DISABLE ON SLAVE COMMENT 'optimize datastore.tblmaster every Saturday evening' DO BEGIN
        slave stop ;
        select sleep(10) into @dsleep ;
        flush NO_WRITE_TO_BINLOG tables ;
        optimize NO_WRITE_TO_BINLOG table datastore.tblmaster, datastore.tblbounces, system.tblglobal_individual ;
        flush NO_WRITE_TO_BINLOG tables ;
        slave start ;
END ;
~
delimiter ;
