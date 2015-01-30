use datastore ;
drop event if exists daily_record_report ;
delimiter ~


CREATE EVENT `daily_record_report` ON SCHEDULE EVERY 1 DAY STARTS '2009-01-29 10:22:00' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'This event creates statistical entries in datastore.record_repor' 
DO BEGIN
        insert into datastore.record_reports (table_name,records)                                                                                                                 
                values ('tblmaster', (select count(*) from datastore.tblmaster))                                                                                                  
                , ('tblglobal_individual', (select count(*) from system.tblglobal_individual))                                                                                    
                , ('tblglobal_domains', (select count(*) from system.tblglobal_domains))                                                                                          
                , ('tblglobal_role', (select count(*) from system.tblglobal_role))
                , ('tblbounces', (select count(*) from datastore.tblbounces)) ;
END ;
~

delimiter ;
