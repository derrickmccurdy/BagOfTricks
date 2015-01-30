-- truncate  datastore.error_log ;  source /tmp/global_opener_clicker.event.sql ; call datastore.global_opener_clicker_sproc() ; select * from datastore.error_log ;

use datastore ;
create table if not exists datastore.global_opener_clicker_temp(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(200) NOT NULL,
  `email_hash` bigint(17) unsigned zerofill NOT NULL,
  `domain` varchar(100) DEFAULT NULL,
  `Confirmed` int(10) unsigned NOT NULL DEFAULT '0',
  `ConfirmedIP` int(10) unsigned NOT NULL DEFAULT '0',
  `ConfirmedTS` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Opener` int(10) unsigned NOT NULL DEFAULT '0',
  `OpenerIP` int(10) unsigned NOT NULL DEFAULT '0',
  `OpenerTS` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Clicker` int(10) unsigned NOT NULL DEFAULT '0',
  `ClickerIP` int(10) unsigned NOT NULL DEFAULT '0',
  `ClickerTS` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `fqtname` varchar(50) default null,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_hash` (`email_hash`)
) ;
-- add truncate to this sproc somewhere appropriateDERRICK

create table if not exists datastore.global_opener_clicker(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `listid` int(10) DEFAULT NULL,
  `email` varchar(200) NOT NULL,
  `email_hash` bigint(17) unsigned zerofill NOT NULL,
  `firstname` varchar(45) NOT NULL,
  `middlename` varchar(45) NOT NULL,
  `lastname` varchar(45) NOT NULL,
  `address` varchar(250) NOT NULL,
  `address2` varchar(250) NOT NULL,
  `city` varchar(95) NOT NULL,
  `county` varchar(100) NOT NULL,
  `region` varchar(25) NOT NULL,
  `zipcode` varchar(20) NOT NULL DEFAULT '0',
  `gender` varchar(5) NOT NULL,
  `companyname` varchar(45) NOT NULL,
  `jobtitle` varchar(45) NOT NULL,
  `industry` varchar(45) NOT NULL,
  `phonearea` varchar(3) NOT NULL,
  `phonenum` varchar(15) NOT NULL,
  `keywords` varchar(250) DEFAULT NULL,
  `born` date NOT NULL DEFAULT '0000-00-00',
  `source` varchar(250) NOT NULL,
  `dtTimeStamp` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `dateadded` date NOT NULL DEFAULT '0000-00-00',
  `ip` int(10) unsigned NOT NULL DEFAULT '0',
  `domain` varchar(100) DEFAULT NULL,
  `exclude` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `Confirmed` int(10) unsigned NOT NULL DEFAULT '0',
  `ConfirmedIP` int(10) unsigned NOT NULL DEFAULT '0',
  `ConfirmedTS` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Opener` int(10) unsigned NOT NULL DEFAULT '0',
  `OpenerIP` int(10) unsigned NOT NULL DEFAULT '0',
  `OpenerTS` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Clicker` int(10) unsigned NOT NULL DEFAULT '0',
  `ClickerIP` int(10) unsigned NOT NULL DEFAULT '0',
  `ClickerTS` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `country_short` varchar(10) NOT NULL,
  `fqtname` varchar(50) default null,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_hash` (`email_hash`),
  KEY `company` (`companyname`),
  KEY `region` (`region`),
  KEY `zip` (`zipcode`),
  KEY `keywords` (`keywords`),
  KEY `country` (`country_short`)
) ;


drop procedure if exists datastore.global_opener_clicker_sproc ;
delimiter ~



create procedure datastore.global_opener_clicker_sproc()
begin
	declare dfqtname varchar(100) default '' ;
	declare dhostname varchar(40) default '' ;
	declare done int default 0 ;
	declare done2 int default 0 ;
	declare done_abandoned int default 0 ;
	declare done_leased int default 0 ;
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
					and dtables.update_time > date_format(date_sub(now(), interval 2 day), '%Y-%m-%d') 
	;

-- get all the list server hostnames into a separate cursor
	declare cur2 cursor for select ip, alias, host_name from system.ls_aliases where alias like "ls%" ;

-- get all list tablenames for this server of abandoned client lists that were uploaded by the user and the accounts have been disabled for more than 90 days.
	declare cur3 cursor for select 
                concat('d',lists.accountid,'.',lists.tableid) as fqtname
                ,ls_aliases.host_name as hostname
                from system.ls_aliases as ls_aliases
                        inner join emarketing.settings as settings on ls_aliases.ip = settings.listserver
-- This should be uncommented after initial run so we only get the most recently abandoned data tables
--			inner join system.accounts as accounts on settings.accountid = accounts.accountid and accounts.accountenabled = 0 and accounts.datedisabled < date_sub(now(), interval 90 day) and accounts.datedisabled > date_sub(now(), interval 92 day)
			inner join system.accounts as accounts on settings.accountid = accounts.accountid and accounts.accountenabled = 0 and accounts.datedisabled < date_sub(now(), interval 90 day)
                        inner join emarketing.lists as lists on settings.accountid = lists.accountid and lists.list_removed = 0 and lists.private = 0
                        inner join information_schema.tables as dtables on concat('d',lists.accountid) = dtables.table_schema and lists.tableid = dtables.table_name
        ;


-- No data - zero rows fetched, selected, or processed --- reached the end of our cursor
        declare continue handler for 1329
        begin
		set done := 1 ;
        end ;

-- prepared statement failed
        declare continue handler for 1243
        begin
                set @error_log_string := CONCAT("insert into datastore.error_log (message) values(\"Prepared statement failed \n",@get_clicker_opener_string,".\n Error encountered while running global_opener_clicker stored procedure on ",@@global.hostname,"\")");
                prepare error_log_statement from @error_log_string ;
                execute error_log_statement ;
                deallocate prepare error_log_statement ;

                set @non_fatal_error_triggered := 1 ;
        end ;

-- crashed table handler
	declare continue handler for 1194
	begin
		set @error_log_string := CONCAT("insert into datastore.error_log (message) values(\"Table ",@dfqtname," was crashed. Error encountered while running global_opener_clicker stored procedure on ",@@global.hostname,"\")");
		prepare error_log_statement from @error_log_string ;
		execute error_log_statement ;
		deallocate prepare error_log_statement ;

		set @non_fatal_error_triggered := 1 ;
	end ;   

-- table does not exist handler
	declare continue handler for 1146
	begin
		set @error_log_string := CONCAT("insert into datastore.error_log (message) values(\"Table ",@dfqtname," does not exist. Error encountered while running global_opener_clicker stored procedure on ",@@global.hostname,"\")");
		prepare error_log_statement from @error_log_string ;
		execute error_log_statement ;
		deallocate prepare error_log_statement ;

		set @non_fatal_error_triggered := 1 ;
	end ;   

-- Unknown colum
        declare continue handler for 1054
        begin
                set @error_log_string := CONCAT("insert into datastore.error_log (message) values(\"Unknown column hit in table ",@dfqtname,". Error encountered while running global_opener_clicker stored procedure on ",@@global.hostname,"\")");
                prepare error_log_statement from @error_log_string ;
                execute error_log_statement ;
                deallocate prepare error_log_statement ;

                set @non_fatal_error_triggered := 1 ;
        end ;


-- iterate through each list on this list server inserting the pertinent information from each list into the temp table		
	open cur1 ;
	open cur2 ;
	open cur3 ;

-- if this is not the main app server...
	if "lxdb145" <> @@global.hostname
	then
-- 	{
		truncate table datastore.global_opener_clicker_temp ;
		list_server_loop : begin 
			repeat 
			get_data_loop : begin
				FETCH cur1 INTO  dfqtname, dhostname ;

				set @dfqtname := dfqtname ; 
				set @dhostname := dhostname ;
				set @non_fatal_error_triggered := 0 ;

				/*set @log_string := concat("insert into datastore.error_log (message) values(\"",@dfqtname,"\")") ;
				prepare log_statement from @log_string ;
				execute log_statement ;
				deallocate prepare log_statement ;*/

				if null = @dhostname
				then 
					set done_leased := 1 ;
					leave list_server_loop ;
				end if ;

				if 0 = done_leased
				then
-- check to see if the hostname is the same as THIS host
					if @@global.hostname = @dhostname
					then

						SET @get_clicker_opener_string := CONCAT("insert into datastore.global_opener_clicker_temp 
								(email 
								,email_hash 
								,domain 
								,Confirmed 
								,ConfirmedIP 
								,ConfirmedTS 
								,Opener 
								,OpenerIP 
								,OpenerTS 
								,Clicker 
								,ClickerIP 
								,ClickerTS) 
								select 
									email 
									,email_hash 
									,domain 
									,Confirmed 
									,ConfirmedIP 
									,ConfirmedTS 
									,Opener 
									,OpenerIP 
									,OpenerTS 
									,Clicker 
									,ClickerIP 
									,ClickerTS 
								from ",@dfqtname," as fqtname where confirmed = 1 or opener = 1 or clicker = 1 or confirmedip <> ''  or openerip <> '' or clickerip <> ''  or confirmedts <> '0000-00-00 00:00:00' or openerts <> '0000-00-00 00:00:00' or clickerts <> '0000-00-00 00:00:00'
							on duplicate key update 
							Confirmed = if(fqtname.confirmed > datastore.global_opener_clicker_temp.confirmed, fqtname.confirmed, datastore.global_opener_clicker_temp.confirmed) 
							,ConfirmedIP = if(fqtname.confirmedip > datastore.global_opener_clicker_temp.confirmedip, fqtname.confirmedip, datastore.global_opener_clicker_temp.confirmedip)
							,ConfirmedTS = if(fqtname.confirmedts > datastore.global_opener_clicker_temp.confirmedts, fqtname.confirmedts, datastore.global_opener_clicker_temp.confirmedts)
							,Opener = if(fqtname.Opener > datastore.global_opener_clicker_temp.Opener, fqtname.Opener, datastore.global_opener_clicker_temp.Opener)
							,OpenerIP = if(fqtname.OpenerIP> datastore.global_opener_clicker_temp.OpenerIP, fqtname.OpenerIP, datastore.global_opener_clicker_temp.OpenerIP)
							,OpenerTS = if(fqtname.OpenerTS> datastore.global_opener_clicker_temp.OpenerTS, fqtname.OpenerTS, datastore.global_opener_clicker_temp.OpenerTS)
							,Clicker = if(fqtname.Clicker > datastore.global_opener_clicker_temp.Clicker, fqtname.Clicker, datastore.global_opener_clicker_temp.Clicker)
							,ClickerIP = if(fqtname.ClickerIP > datastore.global_opener_clicker_temp.ClickerIP, fqtname.ClickerIP, datastore.global_opener_clicker_temp.ClickerIP)
							,ClickerTS = if(fqtname.ClickerTS > datastore.global_opener_clicker_temp.ClickerTS, fqtname.ClickerTS, datastore.global_opener_clicker_temp.ClickerTS) ") ;
						PREPARE get_clicker_opener_statement from @get_clicker_opener_string ;

						if 1 = @non_fatal_error_triggered
						then
							leave get_data_loop ;
						end if ;
						
						EXECUTE get_clicker_opener_statement ;
						DEALLOCATE PREPARE get_clicker_opener_statement ;
					end if ;
				end if ;
-- end get_data_loop
			end ;
-- end repeat
			until 1 = done_leased end repeat ;
			close cur1 ;

			repeat 
			get_abandoned_data_loop : begin
				FETCH cur3 INTO  dfqtname, dhostname ;

				set @dfqtname := dfqtname ; 
				set @dhostname := dhostname ;
				set @non_fatal_error_triggered := 0 ;

				/*set @log_string := concat("insert into datastore.error_log (message) values(\"",@dfqtname,"\")") ;
				prepare log_statement from @log_string ;
				execute log_statement ;
				deallocate prepare log_statement ;*/

				if null = @dhostname
				then 
					set done_abandoned := 1 ;
					leave get_abandoned_data_loop ;
				end if ;

				if 0 = done_abandoned
				then
-- check to see if the hostname is the same as THIS host
					if @@global.hostname = @dhostname
					then

						SET @get_clicker_opener_string := CONCAT("insert into datastore.global_opener_clicker_temp 
								(email 
								,email_hash 
								,domain 
								,Confirmed 
								,ConfirmedIP 
								,ConfirmedTS 
								,Opener 
								,OpenerIP 
								,OpenerTS 
								,Clicker 
								,ClickerIP 
								,ClickerTS) 
								select 
									email 
									,email_hash 
									,domain 
									,Confirmed 
									,ConfirmedIP 
									,ConfirmedTS 
									,Opener 
									,OpenerIP 
									,OpenerTS 
									,Clicker 
									,ClickerIP 
									,ClickerTS 
								from ",@dfqtname," as fqtname where confirmed = 1 or opener = 1 or clicker = 1 or confirmedip <> ''  or openerip <> '' or clickerip <> ''  or confirmedts <> '0000-00-00 00:00:00' or openerts <> '0000-00-00 00:00:00' or clickerts <> '0000-00-00 00:00:00'
							on duplicate key update 
							Confirmed = if(fqtname.confirmed > datastore.global_opener_clicker_temp.confirmed, fqtname.confirmed, datastore.global_opener_clicker_temp.confirmed) 
							,ConfirmedIP = if(fqtname.confirmedip > datastore.global_opener_clicker_temp.confirmedip, fqtname.confirmedip, datastore.global_opener_clicker_temp.confirmedip)
							,ConfirmedTS = if(fqtname.confirmedts > datastore.global_opener_clicker_temp.confirmedts, fqtname.confirmedts, datastore.global_opener_clicker_temp.confirmedts)
							,Opener = if(fqtname.Opener > datastore.global_opener_clicker_temp.Opener, fqtname.Opener, datastore.global_opener_clicker_temp.Opener)
							,OpenerIP = if(fqtname.OpenerIP> datastore.global_opener_clicker_temp.OpenerIP, fqtname.OpenerIP, datastore.global_opener_clicker_temp.OpenerIP)
							,OpenerTS = if(fqtname.OpenerTS> datastore.global_opener_clicker_temp.OpenerTS, fqtname.OpenerTS, datastore.global_opener_clicker_temp.OpenerTS)
							,Clicker = if(fqtname.Clicker > datastore.global_opener_clicker_temp.Clicker, fqtname.Clicker, datastore.global_opener_clicker_temp.Clicker)
							,ClickerIP = if(fqtname.ClickerIP > datastore.global_opener_clicker_temp.ClickerIP, fqtname.ClickerIP, datastore.global_opener_clicker_temp.ClickerIP)
							,ClickerTS = if(fqtname.ClickerTS > datastore.global_opener_clicker_temp.ClickerTS, fqtname.ClickerTS, datastore.global_opener_clicker_temp.ClickerTS) ") ;
						PREPARE get_clicker_opener_statement from @get_clicker_opener_string ;

						if 1 = @non_fatal_error_triggered
						then
							leave get_abandoned_data_loop ;
						end if ;
						
						EXECUTE get_clicker_opener_statement ;
						DEALLOCATE PREPARE get_clicker_opener_statement ;
					end if ;
				end if ;

				if null = @
				then
					set get_abandoned_data_done := 1 ;
					leave get_abandoned_data_loop ;
				end if ;

				until 1 = get_abandoned_data_done end repeat ;
-- end get_abandoned_data_loop
			end ;

			if null = @dhostname
			then 
				set done := 1 ;
				leave list_server_loop ;
			end if ;


-- end repeat
			until 1 = done end repeat ;
			close cur3 ;

-- end list_server_loop
		end ;
-- send all the data from datastore.global_opener_clicker_temp to an outfile on the /expedite
		select concat(date_format(now(), '%Y-%m-%d'),'_',@@global.hostname) into @outfile_suffix ; 
		select concat(date_format(now(), '%Y-%m-%d'),'_') into @outfile_suffix_base ;
		set @outfile_string := concat("select * into outfile '/expedite/mylogin_uploaded/",@outfile_suffix,".csv' fields terminated by ',' optionally enclosed by '\"' lines terminated by '\n' from datastore.global_opener_clicker_temp") ;
		prepare outfile_statement from @outfile_string ;
		execute outfile_statement ;
		deallocate prepare outfile_statement ;
-- end list server check
--	}
	end if ;
/*
-- if this is the main app server...
	if "lxdb145" = @@global.hostname
	then
		main_app_loop : begin 
		select concat(date_format(now(), '%Y-%m-%d'),'_') into @outfile_suffix_base ;
-- load the data from all the outfiles into datastore.global_opener_clicker
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
--					set @load_data_string := concat("load data infile '/expedite/mylogin_uploaded/",@outfile_suffix_base,@ddhostname,"' replace into table datastore.global_opener_clicker fields terminated by ',' optionally enclosed by '\"' lines terminated by '\n' (@discard_id, email ,email_hash ,domain ,Confirmed ,ConfirmedIP ,ConfirmedTS ,Opener ,OpenerIP ,OpenerTS ,Clicker ,ClickerIP ,ClickerTS)") ;
					set @load_data_string := concat("load data infile '/expedite/mylogin_uploaded/",@outfile_suffix_base,@ddhostname,"' replace into table datastore.global_opener_clicker fields terminated by ',' optionally enclosed by '\"' lines terminated by '\n' (@discard_id, email ,email_hash ,domain ,Confirmed ,ConfirmedIP ,ConfirmedTS ,Opener ,OpenerIP ,OpenerTS ,Clicker ,ClickerIP ,ClickerTS)") ;
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

-- pull in the other data from datastore.tblmaster into global_opener_clicker
	update datastore.global_opener_clicker as oc inner join datastore.tblmaster as master on oc.email_hash = master.email_hash set oc.firstname = master.firstname ,oc.middlename = master.middlename ,oc.lastname = master.lastname ,oc.address = master.address ,oc.address2 = master.address2, oc.city = master.city ,oc.county = master.county ,oc.region = master.region ,oc.zipcode = master.zipcode, oc.gender = master.gender ,oc.companyname = master.companyname ,oc.jobtitle = master.jobtitle, oc.industry = master.industry ,oc.phonearea = master.phonearea, oc.phonenum = master.phonenum ,oc.keywords = master.keywords , oc.born = master.born , oc.source = master.source , oc.dtTimeStamp = master.dtTimeStamp , oc.dateadded = master.dtTimeStamp ,oc.ip = master.ip , oc.country_short = master.country_short ;

	end if ;*/
-- end procedure
end ;

~
delimiter ;



drop event if exists datastore.global_opener_clicker_event ;
delimiter ~




-- The event needs to be sheduled differently on the main app server than on the list servers so that the app server is not trying to load data from files that do not yet exist.
CREATE EVENT datastore.global_opener_clicker_event ON SCHEDULE EVERY 1 DAY STARTS '2010-08-17 03:12:00' ON COMPLETION PRESERVE ENABLE COMMENT 'retreive all openers and clickers from leased lists' 
DO BEGIN
	call datastore.global_opener_clicker_sproc() ;
END ;
~
delimiter ;



