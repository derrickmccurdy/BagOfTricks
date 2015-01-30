/*
describe datastore.disk_space ; describe system.ls_aliases ;
+-------------+-------------+------+-----+-------------------+-----------------------------+
| Field       | Type        | Null | Key | Default           | Extra                       |
+-------------+-------------+------+-----+-------------------+-----------------------------+
| id          | int(10)     | NO   | PRI | NULL              | auto_increment              | 
| server      | varchar(20) | NO   | MUL | NULL              |                             | 
| available   | varchar(10) | NO   |     | NULL              |                             | 
| used        | varchar(10) | NO   |     | NULL              |                             | 
| date_added  | timestamp   | NO   |     | CURRENT_TIMESTAMP | on update CURRENT_TIMESTAMP | 
| total_space | varchar(20) | YES  |     | NULL              |                             | 
| numeric_ip  | int(10)     | NO   | MUL | 0                 |                             | 
+-------------+-------------+------+-----+-------------------+-----------------------------+
7 rows in set (0.00 sec)

+------------+-------------+------+-----+---------+-------+
| Field      | Type        | Null | Key | Default | Extra |
+------------+-------------+------+-----+---------+-------+
| ip         | varchar(30) | NO   | PRI | NULL    |       | 
| alias      | varchar(30) | NO   | UNI | NULL    |       | 
| host_name  | varchar(30) | YES  |     | NULL    |       | 
| numeric_ip | int(10)     | NO   | MUL | 0       |       | 
+------------+-------------+------+-----+---------+-------+

*/

use datastore ;
-- use derrick ;
drop trigger if exists datastore.before_insert_diskspace_trigger ; 
delimiter ~

create trigger datastore.before_insert_diskspace_trigger before insert on datastore.disk_space 
	for each row  
	begin 
-- 	{
		set NEW.numeric_ip := inet_aton(NEW.server) ;
-- 	}
	end ;

~

delimiter ;
