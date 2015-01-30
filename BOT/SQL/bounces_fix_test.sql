-- create table if not exists datastore.tblbounces_clone like datastore.tblbounces ;

-- create table if not exists system.tblglobal_individual_clone like system.tblglobal_individual ;


-- alter table datastore.tblbounces add column campaign_id int(10) ;
-- alter table datastore.tblbounces change column email_hash email_hash (bigint(17) unsigned zerofill not null ;

/*
datastore.tblbounces ;      
| custid     | varchar(10)                  | NO   |     | NULL              |                | 
| email      | varchar(255)                 | NO   |     | NULL              |                | 
| date_added | timestamp                    | NO   | MUL | CURRENT_TIMESTAMP |                | 
| id         | int(10)                      | NO   | PRI | NULL              | auto_increment | 
| Status     | tinyint(3) unsigned          | NO   | MUL | 0                 |                | 
| email_hash | bigint(17) unsigned zerofill | NO   | UNI | NULL              |                | 
| campaign_id| int(10)


select * from system.ls_aliases ;
+---------------+---------+-----------+
| ip            | alias   | host_name |
+---------------+---------+-----------+
| 67.217.39.105 | master  | lxls51    | 
| 67.217.39.116 | lsim0   | lxls50    | 
| 67.217.39.104 | lsim1   | lxls67    | 

*/
delimiter ;
use datastore ;
drop event if exists mark_client_bounces ;
drop procedure if exists mark_client_bounces ;
delimiter ~

CREATE EVENT datastore.mark_client_bounces ON SCHEDULE EVERY 5 MINUTE STARTS '2009-03-19 02:12:00' ON COMPLETION PRESERVE ENABLE COMMENT 'This event copies bounces from datastore.tblbounces to client list tables'
DO BEGIN
	call datastore.mark_client_bounces() ;
END ;




create procedure datastore.mark_client_bounces()
BEGIN
	DECLARE this_ip varchar(20) default "" ;
	DECLARE dTableID varchar(100) default "" ;
        DECLARE done INT DEFAULT 0 ;
	DECLARE dsdate timestamp ;
	DECLARE dAccountID int(10) default 0 ;

-- 	get local hostname from global variables ;
	select ip into this_ip from system.ls_aliases where host_name = @@global.hostname  ;

	set @this_ip := this_ip ;
	set @num_tables := 0 ;
	
	BEGIN
-- 	get bounce list names from last five minutes for this list server
--	datastore.tblbounces, emarketing.settings, emarketing.campaigns, system.ls_aliases
		declare cur1 cursor for select date_sub(now(), interval 2 day ) as sdate, concat("d",campaigns.AccountID, ".", campaigns.ListID) as TableID, campaigns.AccountID as AccountID
			from datastore.tblbounces as bounces inner join emarketing.settings as settings on bounces.custid = settings.AccountID 
				inner join emarketing.campaigns as campaigns on bounces.campaign_id = campaigns.id 
				inner join system.ls_aliases as aliases on settings.ListServer = aliases.ip
			where aliases.ip = this_ip and bounces.date_added >= date_sub(now(), interval 2 day ) group by campaigns.ListID order by campaigns.AccountID ;

		OPEN cur1 ;

		REPEAT  
			BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '42S02'
			BEGIN
				SET @missing_table_error_triggered := 1 ;
			END ;
			
			SET @missing_table_error_triggered := 0 ;

			FETCH cur1 INTO  dsdate, dTableID, dAccountID ;

			SET @TableID := dTableID ;
			SET @dsdate := dsdate ;
			SET @AccountID := dAccountID ;
			
			IF "" = @TableID
			THEN
				set done := 1 ;
			ELSE
-- 			update the client tables with the bounce status of all records in bounce table from last five minutes			
				SET @update_string := CONCAT("update ",@TableID," as client_table inner join datastore.tblbounces as bounces on client_table.email_hash = bounces.email_hash  set client_table.Status = bounces.Status where bounces.date_added >= \"", @dsdate, "\" and bounces.custid = ",@AccountID ) ;
				PREPARE  update_statement from @update_string ;
				EXECUTE update_statement ;
				IF 0 = @missing_table_error_triggered
				THEN
					DEALLOCATE PREPARE update_statement ;
				END IF ;
			END IF ;


			set @num_tables := @num_tables + 1 ;

			SET @update_string := "" ;
			END ;
		UNTIL 1 = done END REPEAT ;
		CLOSE cur1 ;
-- 		delete records from tblbounces where status indicates domain not found. Those are copied by a trigger into a new table.
 		delete from datastore.tblbounces where Status = 85 ;
	END ;

-- 	mark bounces in client tables on this list server

end ;
~

delimiter ;


-- we will need to replicate emarketing.campaigns to all the list servers.
-- we will need to replicate system.ls_aliases

