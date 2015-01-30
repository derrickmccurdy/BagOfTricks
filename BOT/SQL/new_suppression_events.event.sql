/*mysql> show triggers from system ;
+---------------------+--------+----------------------+------------------------------------------------------------------------------------------------------------------------+--------+---------+----------+-----------------+----------------------+----------------------+--------------------+
| Trigger             | Event  | Table                | Statement                                                                                                              | Timing | Created | sql_mode | Definer         | character_set_client | collation_connection | Database Collation |
+---------------------+--------+----------------------+------------------------------------------------------------------------------------------------------------------------+--------+---------+----------+-----------------+----------------------+----------------------+--------------------+
| domain_suppress     | INSERT | tblglobal_domains    | begin
delete from datastore.tblmaster where domain like NEW.domain_name
;
end                                          | AFTER  | NULL    |          | admin@localhost | latin1               | latin1_swedish_ci    | latin1_swedish_ci  | 
| individual_suppress | INSERT | tblglobal_individual | begin
delete from datastore.tblmaster where email_hash = conv(substr(md5(lower(NEW.email)),19,32),16,10) LIMIT 1 ;
end | AFTER  | NULL    |          | admin@localhost | latin1               | latin1_swedish_ci    | latin1_swedish_ci  | 
| role_suppress       | INSERT | tblglobal_role       | begin
delete from datastore.tblmaster where email like NEW.role_name ;
end                                             | AFTER  | NULL    |          | admin@localhost | latin1               | latin1_swedish_ci    | latin1_swedish_ci  | 
+---------------------+--------+----------------------+------------------------------------------------------------------------------------------------------------------------+--------+---------+----------+-----------------+----------------------+----------------------+--------------------+
3 rows in set (0.01 sec)
*/



/*
mysql> show create trigger system.individual_suppress ;
+---------------------+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+--------------------+
| Trigger             | sql_mode | SQL Original Statement                                                                                                                                                                                                                         | character_set_client | collation_connection | Database Collation |
+---------------------+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+--------------------+
| individual_suppress |          | CREATE DEFINER=`admin`@`localhost` trigger system.individual_suppress after insert on tblglobal_individual
for each row
begin
delete from datastore.tblmaster where email_hash = conv(substr(md5(lower(NEW.email)),19,32),16,10) LIMIT 1 ;
end | latin1               | latin1_swedish_ci    | latin1_swedish_ci  | 
+---------------------+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+--------------------+
1 row in set (0.01 sec)
*/
use system ;
drop event if exists individual_suppress_event ;
delimiter ~

CREATE EVENT individual_suppress_event ON SCHEDULE EVERY 1 DAY STARTS '2009-03-19 02:12:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Suppresses individuals in datastore.tblmaster' 
DO BEGIN

	SET @aff_rows = 0 ;
	SELECT @prior_count := count(*) from datastore.tblmaster ;
	SELECT @records := count(*) from system.tblglobal_individual ;

	UPDATE system.tblglobal_individual set email_hash = conv(substr(md5(lower(email)),19,32),16,10) where email_hash = 0 or email_hash is null ;

	DELETE datastore.tblmaster as master from datastore.tblmaster as master inner join system.tblglobal_individual as individual on individual.email_hash = master.email_hash where DATE_FORMAT(individual.tsAdded,'%Y-%m-%d') =  DATE_FORMAT(DATE_DUB(current_date(), INTERVAL 1 DAY),'%Y-%m-%d') ;

	SET @description = "individual_suppression" ;
	SELECT @post_count := count(*) FROM datastore.tblmaster ;
	SELECT @aff_rows := @prior_count - @post_count ;
	INSERT INTO datastore.record_reports (date_added, table_name,records,affected_rows,prior_count, post_count,description) values(now(), "tblglobal_individual", @records, @aff_rows, @prior_count, @post_count, @description) ;

END ;
~
delimiter ;








/*
mysql> show create trigger datastore.bounce_removal ;
+----------------+----------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------+----------------------+----------------------+--------------------+
| Trigger        | sql_mode | SQL Original Statement                                                                                                                                                                                        
           | character_set_client | collation_connection | Database Collation |
+----------------+----------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------+----------------------+----------------------+--------------------+
| bounce_removal |          | CREATE DEFINER=`admin`@`localhost` trigger bounce_removal after insert on datastore.tblbounces
for each row
begin
delete from tblmaster where email_hash = conv(substr(md5(lower(NEW.email)),19,32),16,10) LIMIT 1 ;
end | latin1               | latin1_swedish_ci    | latin1_swedish_ci  | 
+----------------+----------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------+----------------------+----------------------+--------------------+
*/
/*
use datastore ;
drop event if exists bounce_removal_event ;
delimiter ~

CREATE EVENT bounce_removal_event ON SCHEDULE EVERY 1 DAY STARTS '2009-03-19 02:17:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Suppresses individuals in datastore.tblmaster' 
DO BEGIN
*/
	SET @aff_rows = 0 ;
	SELECT @prior_count := count(*) from datastore.tblmaster ;
	SELECT @records := count(*) from datastore.tblbounces ;

	UPDATE datastore.tblbounces set email_hash = conv(substr(md5(lower(email)),19,32),16,10) where email_hash = 0 or email_hash is null;

	DELETE datastore.tblmaster as master from datastore.tblmaster as master inner join datastore.tblbounces as bounces on bounces.email_hash = master.email_hash where DATE_FORMAT(bounces.date_added,'%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),'%Y-%m-%d')  ;

	SET @description = "bounce_removal" ;
	SELECT @post_count := count(*) FROM datastore.tblmaster ;
	SELECT @aff_rows := @prior_count - @post_count ;
	INSERT INTO datastore.record_reports (date_added, table_name,records,affected_rows,prior_count, post_count,description) values(now(), "tblbounces", @records, @aff_rows, @prior_count, @post_count, @description) ;
/*
END ;
~
delimiter ;
*/









/*
mysql> show create trigger system.domain_suppress ;
+-----------------+----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+--------------------+
| Trigger         | sql_mode | SQL Original Statement                                                                                                                                                                  | character_set_client | collation_connection | Database Collation |
+-----------------+----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+--------------------+
| domain_suppress |          | CREATE DEFINER=`admin`@`localhost` trigger domain_suppress after insert on tblglobal_domains
for each row
begin
delete from datastore.tblmaster where domain like NEW.domain_name
;
end | latin1               | latin1_swedish_ci    | latin1_swedish_ci  | 
+-----------------+----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+--------------------+
1 row in set (0.00 sec)
*/
/*
use system ;
drop event if exists domain_suppress_event ;
delimiter ~

CREATE EVENT domain_suppress_event ON SCHEDULE EVERY 1 DAY STARTS '2009-03-19 02:32:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Suppresses domains in datastore.tblmaster' 
DO BEGIN
*/
	SET @aff_rows = 0 ;
	SELECT @prior_count := count(*) from datastore.tblmaster ;
	SELECT @records := count(*) from system.tblglobal_domains ;

        SELECT group_concat(domain_name separator ";") from system.tblglobal_domains where DATE_FORMAT(tsAdded,'%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),'%Y-%m-%d')  into @domain_wildcards ;

        IF @domain_wildcards IS NOT NULL
        THEN
                SET @domain_string2 = CONCAT("DELETE FROM datastore.tblmaster where (email like \"", REPLACE(@domain_wildcards, ";", "\" or email like \""), "\" )" ) ;
                PREPARE domain_statement2 FROM @domain_string2 ;
                EXECUTE domain_statement2 ;
                DEALLOCATE PREPARE domain_statement2 ;

        END IF ;

	SET @description = "domain_suppression" ;
	SELECT @post_count := count(*) FROM datastore.tblmaster ;
	SELECT @aff_rows := @prior_count - @post_count ;
	INSERT INTO datastore.record_reports (date_added, table_name,records,affected_rows,prior_count, post_count,description) values(now(), "tblglobal_domains", @records, @aff_rows, @prior_count, @post_count, @description) ;
/*
END ;
~
delimiter ;
*/







/*mysql> show create trigger system.role_suppress ;
+---------------+----------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+--------------------+
| Trigger       | sql_mode | SQL Original Statement                                                                                                                                                          | character_set_client | collation_connection | Database Collation |
+---------------+----------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+--------------------+
| role_suppress |          | CREATE DEFINER=`admin`@`localhost` trigger role_suppress after insert on tblglobal_role
for each row
begin
delete from datastore.tblmaster where email like NEW.role_name ;
end | latin1               | latin1_swedish_ci    | latin1_swedish_ci  | 
+---------------+----------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+--------------------+
1 row in set (0.01 sec)*/
/*
use system ;
drop event if exists role_suppress_event ;
delimiter ~

CREATE EVENT role_suppress_event` ON SCHEDULE EVERY 1 DAY STARTS '2009-03-19 04:32:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Suppresses roles in datastore.tblmaster' 
DO BEGIN
*/
	SET @aff_rows = 0 ;
	SELECT @prior_count := count(*) from datastore.tblmaster ;
	SELECT @records := count(*) from system.tblglobal_role ;

        SELECT group_concat(role_name separator ";") from system.tblglobal_role where DATE_FORMAT(tsAdded, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(current_date(), INTERVAL 1 DAY), '%Y-%m-%d')  into @roles ;

        IF @roles IS NOT NULL
        THEN
                SET @role_string = CONCAT("DELETE FROM datastore.tblmaster where (email like \"", REPLACE(@roles, ";", "\" or email like \""), "\" )" ) ;
                PREPARE role_statement FROM @role_string ;
                EXECUTE role_statement ;
                DEALLOCATE PREPARE role_statement ;

        END IF ;

	SET @description = "role_suppression" ;
	SELECT @post_count := count(*) FROM datastore.tblmaster ;
	SELECT @aff_rows := @prior_count - @post_count ;
	INSERT INTO datastore.record_reports (date_added, table_name, records,affected_rows,prior_count, post_count,description) values(now(), "tblglobal_role", @records, @aff_rows, @prior_count, @post_count, @description) ;

END ;
~
delimiter ;









