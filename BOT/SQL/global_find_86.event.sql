-- truncate  datastore.error_log ;  source /tmp/global_find_86.event.sql ; call datastore.global_address_not_exist_sproc() ; select * from datastore.error_log ;

use datastore ;
create table if not exists datastore.global_address_not_exist_temp(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) not null,
  `email_hash` bigint(17) unsigned zerofill NOT NULL,
  `status` tinyint(1) unsigned not null,
  `fqtname` varchar(50) default null,
  `dings` int(10) default 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_hash` (`email_hash`)
) ;

create table if not exists datastore.global_address_not_exist(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) not null,
  `email_hash` bigint(17) unsigned zerofill NOT NULL,
  `status` tinyint(1) unsigned not null,
  `fqtname` varchar(50) default null,
  `dings` int(10) default 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_hash` (`email_hash`)
) ;

drop procedure if exists datastore.global_address_not_exist_sproc ;
delimiter ~


create procedure datastore.global_address_not_exist_sproc()
begin
	declare dfqtname varchar(100) default '' ;
	declare dhostname varchar(40) default '' ;
	declare done int default 0 ;
	declare done2 int default 0 ;
	declare ddip varchar(20) default '' ;
	declare ddalias varchar(20) default '' ;
	declare ddhostname varchar(20) default '' ;

-- get all the leased list tablenames for this list server
	declare cur1 cursor for select 
		concat('d',lists.accountid,'.',lists.tableid) as fqtname
		,ls_aliases.host_name as hostname
		from system.ls_aliases as ls_aliases 
			inner join emarketing.settings as settings on ls_aliases.ip = settings.listserver
			inner join emarketing.lists as lists on settings.accountid = lists.accountid and lists.list_removed = 0 and lists.private = 1
-- This should be uncommented after the initial run. This bit can take an inordinately long time... Not sure HOW long yet...
			inner join information_schema.tables as dtables on concat('d',lists.accountid) = dtables.table_schema and lists.tableid = dtables.table_name 
					and dtables.update_time > date_format(date_sub(now(), interval 24 hour), '%Y-%m-%d') 
	;

-- get all the list server hostnames into a separate cursor
	declare cur2 cursor for select ip, alias, host_name from system.ls_aliases where alias like "ls%" ;

-- No data - zero rows fetched, selected, or processed --- reached the end of our cursor
        declare continue handler for 1329
        begin
		set done := 1 ;
        end ;

-- prepared statement failed
        declare continue handler for 1243
        begin
                set @error_log_string := CONCAT("insert into datastore.error_log (message) values(\"Prepared statement  failed \n",@get_clicker_opener_string,".\n Error encountered while running global_address_not_exist_sproc stored procedure on ",@@global.hostname,"\")");
                prepare error_log_statement from @error_log_string ;
                execute error_log_statement ;
                deallocate prepare error_log_statement ;

                set @non_fatal_error_triggered := 1 ;
        end ;

-- crashed table handler
	declare continue handler for 1194
	begin
		set @error_log_string := CONCAT("insert into datastore.error_log (message) values(\"Table ",@dfqtname," was crashed. Error encountered while running global_address_not_exist_sproc stored procedure on ",@@global.hostname,"\")");
		prepare error_log_statement from @error_log_string ;
		execute error_log_statement ;
		deallocate prepare error_log_statement ;

		set @non_fatal_error_triggered := 1 ;
	end ;   

-- table does not exist handler
	declare continue handler for 1146
	begin
		set @error_log_string := CONCAT("insert into datastore.error_log (message) values(\"Table ",@dfqtname," does not exist. Error encountered while running global_address_not_exist_sproc stored procedure on ",@@global.hostname,"\")");
		prepare error_log_statement from @error_log_string ;
		execute error_log_statement ;
		deallocate prepare error_log_statement ;

		set @non_fatal_error_triggered := 1 ;
	end ;   

-- Unknown colum
        declare continue handler for 1054
        begin
                set @error_log_string := CONCAT("insert into datastore.error_log (message) values(\"Unknown column hit in table ",@dfqtname,". Error encountered while running global_address_not_exist_sproc stored procedure on ",@@global.hostname,"\")");
                prepare error_log_statement from @error_log_string ;
                execute error_log_statement ;
                deallocate prepare error_log_statement ;

                set @non_fatal_error_triggered := 1 ;
        end ;


-- iterate through each list on this list server inserting the pertinent information from each list into the temp table		
	open cur1 ;
	open cur2 ;


-- if this is NOT the main app server...
	if "lxdb145" <> @@global.hostname
	then
		truncate table datastore.global_address_not_exist_temp ;
		list_server_loop : begin 
			repeat 
			get_data_loop : begin
				FETCH cur1 INTO  dfqtname, dhostname ;

				set @dfqtname := dfqtname ; 
				set @dhostname := dhostname ;
				set @non_fatal_error_triggered := 0 ;

				if null = @dhostname
				then 
					set done := 1 ;
					leave list_server_loop ;
				end if ;

				if 0 = done
				then
-- check to see if the hostname is the same as THIS host
					if @@global.hostname = @dhostname
					then

						SET @get_86_string := CONCAT("insert into datastore.global_address_not_exist_temp 
								(email
								,email_hash 
								,status
								,fqtname) 
								select 
									email
									,email_hash 
									,status 
									,\"",@dfqtname,"\" 
								from ",@dfqtname," as fqtname where status = 86
							on duplicate key update 
							dings = dings + 1 ") ;
						PREPARE get_86_statement from @get_86_string ;

						if 1 = @non_fatal_error_triggered
						then
							leave get_data_loop ;
						end if ;
						
						EXECUTE get_86_statement ;
						DEALLOCATE PREPARE get_86_statement ;
					end if ;
				end if ;
-- end get_data_loop
			end ;
-- end repeat
			until 1 = done end repeat ;
			close cur1 ;
-- end list_server_loop
		end ;
-- send all the data from datastore.global_address_not_exist_temp to an outfile on the /expedite/mylogin_uploaded NFS mount
		select concat("86_",date_format(now(), '%Y-%m-%d'),'_',@@global.hostname) into @outfile_suffix ; 
		select concat("86_",date_format(now(), '%Y-%m-%d'),'_') into @outfile_suffix_base ;
		set @outfile_string := concat("select * into outfile '/expedite/mylogin_uploaded/",@outfile_suffix,".csv' fields terminated by ',' optionally enclosed by '\"' lines terminated by '\n' from datastore.global_address_not_exist_temp") ;
		prepare outfile_statement from @outfile_string ;
		execute outfile_statement ;
		deallocate prepare outfile_statement ;
-- end list server check
	end if ;
-- if this is the main app server...
/*	if "lxdb145" = @@global.hostname
	then
		main_app_loop : begin 
-- load the data from all the outfiles into datastore.global_address_not_exist_temp on the app server and from there into datastore.global_address_not_exist
			repeat 
			load_data_loop : begin
				FETCH cur2 INTO  ddip, ddalias, ddhostname ;

				set @ddip := ddip;
				set @ddalias := ddalias ;
				set @ddhostname := ddhostname ;
			
				if @ddip is null
				then
					set done2 := 1 ;
					leave main_app_loop ;
				end if ;

				if 0 = done2
				then
					truncate table datastore.global_address_not_exist_temp ;
					set @load_data_string := concat("load data infile '/expedite/mylogin_uploaded/",@outfile_suffix_base,@ddhostname,"' ignore into table datastore.global_address_not_exist_temp fields terminated by ',' optionally enclosed by '\"' lines terminated by '\n' (@discard_id, email,email_hash, status, fqtname, dings )") ;
					prepare load_data_statement from @load_data_string ;
					if 1 = @non_fatal_error_triggered
					then
						leave load_data_loop ;
					end if ;
					execute load_data_statement ;
					deallocate prepare load_data_statement ;



					set @load_data_string := concat("insert into datastore.global_address_not_exist (email, email_hash, status, fqtname, dings ) select email, email_hash, status, fqtname, dings from datastore.global_address_not_exist_temp  on duplicate key update datastore.global_address_not_exist.dings = datastore.global_address_not_exist.dings + datastore.global_address_not_exist_temp.dings") ;
					prepare load_data_statement from @load_data_string ;
					if 1 = @non_fatal_error_triggered
					then
						leave load_data_loop ;
					end if ;
					execute load_data_statement ;
					deallocate prepare load_data_statement ;

				end if ;
-- end load_data_loop
			end ;
-- end repeat
			until 1 = done2 end repeat ;
			close cur2 ;
-- end main_app_loop
		end ;

	end if ;*/
-- end procedure
end ;

~
delimiter ;



drop event if exists datastore.global_address_not_exist_event ;
delimiter ~




-- The event needs to be sheduled differently on the main app server than on the list servers so that the app server is not trying to load data from files that do not yet exist.
CREATE EVENT datastore.global_address_not_exist_event ON SCHEDULE EVERY 1 DAY STARTS '2010-08-20 07:12:00' ON COMPLETION PRESERVE ENABLE COMMENT 'retreive all address does not exist status records from leased lists' 
DO BEGIN
	call datastore.global_address_not_exist_sproc() ;
END ;
~
delimiter ;



