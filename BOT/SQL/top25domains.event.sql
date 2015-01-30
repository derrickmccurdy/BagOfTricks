create table if not exists datastore.top25domains (domain varchar(40), recipients int(10), percent_data float(3,3)) ;

drop event if exists datastore.top_domains ;

delimiter ~

CREATE EVENT datastore.top_domains ON SCHEDULE EVERY 7 DAY STARTS '2009-12-18 02:12:00' ON COMPLETION PRESERVE ENABLE COMMENT 'This event inserts records into the datastore.top25domains table'
DO BEGIN
        DECLARE total_d_size int(10) default 0 ;
        select count(email_hash) as total_data_size into total_d_size from datastore.tblmaster ;
        truncate table datastore.top25domains ;
        insert into datastore.top25domains (domain, recipients) select domain, count(domain) as recips from datastore.tblmaster group by domain order by recips desc limit 25 ;
        update datastore.top25domains set percent_data = recipients / total_d_size ;
end ;

~

delimiter ;

