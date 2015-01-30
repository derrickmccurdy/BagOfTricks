CREATE PROCEDURE datastore.remove_dups(IN db_table VARCHAR(100))
BEGIN
	DECLARE CONTINUE HANDLER FOR SQLSTATE '42S21'
        BEGIN
--                SELECT CONCAT(db_table, " already has an id column. Continuing on." ) ;
        END ;

        SET @dbtable = db_table ;

	SET @alter_string = CONCAT("alter table ", @dbtable, " add column id int(10) auto_increment not null unique") ;
	PREPARE alter_statement FROM @alter_string ;
	EXECUTE alter_statement ;
	DEALLOCATE PREPARE alter_statement ;

        SET @create_tmp_string = CONCAT("create table datastore.dups select max(id) as id from ", @dbtable, "  group by email having count(`email`) > 1") ;
        PREPARE create_statement FROM @create_tmp_string ;
        EXECUTE create_statement ;         
	DEALLOCATE PREPARE create_statement ;

	SET @delete_string = CONCAT("delete  ", @dbtable, " as client_table from ", @dbtable, " as client_table inner join datastore.dups as dups on client_table.id = dups.id") ;
        PREPARE delete_statement FROM @delete_string ;
        EXECUTE delete_statement ;
        DEALLOCATE PREPARE delete_statement ;

        SET @drop_string = CONCAT("drop table datastore.dups"," ") ;
        PREPARE drop_statement FROM @drop_string ;
        EXECUTE drop_statement ;
        DEALLOCATE PREPARE drop_statement ;
END

