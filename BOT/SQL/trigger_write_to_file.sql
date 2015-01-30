USE emarketing ;

DELIMITER $

-- emarketing.settings.ListServer
CREATE TRIGGER `change_list_server` BEFORE UPDATE on `settings`
FOR EACH ROW BEGIN
IF NEW.ListServer != OLD.ListServer THEN
	INSERT into list_server_transfers (former_list_server, new_list_server, AccountID, transfer_status) values (OLD.ListServer, NEW.ListServer, OLD.AccountID, "not_processed") ;
END IF;
END$

DELIMITER ;


#!/bin/bash

#get this servers IP address
this_ip=`ifconfig -a | grep -o "ddr:216.66.17.[^ ]*" | grep -o "216.66.17.[^ ]*"`
echo "this_ip="$this_ip

id_prelim=`mysql -e "select * from emarketing.list_server_transfers where former_list_server = \"$this_ip\" AND transfer_status = 'not_processed' LIMIT 1" -u admin --password=spiedlen -h 216.66.17.201`

#id former_list_server new_list_server AccountID transfer_status 1 216.66.17.198 216.66.17.197 6870 not_processed
#echo $id_prelim | cut -d' ' -f6-10
id=`echo $id_prelim | cut -d' ' -f6`
echo $id

former_list_server=`echo $id_prelim | cut -d' ' -f7`
echo $former_list_server

new_list_server = `echo $id_prelim | cut -d' ' -f8`
echo $new_list_server

AccountID=`echo $id_prelim | cut -d' ' -f9`
echo $AccountID

transfer_status=`echo $id_prelim | cut -d' ' -f10`
echo $transfer_status




#get the id of a record to work on
id_prelim=`mysql -e "select id from emarketing.list_server_transfers where former_list_server = \"$this_ip\" AND transfer_status = 'not_processed' LIMIT 1" -u admin --password=spiedlen -h 216.66.17.201`
id=`echo $id_prelim | grep -o "" `
#get the accountID of that record
AccountID=`mysql -e "select AccountID from emarketing.list_server_transfers where former_list_server = \"$this_ip\" AND transfer_status = 'not_processed' LIMIT 1" -u admin --password=spiedlen -h 216.66.17.201`
$AccountID=`mysql -e "select AccountID from emarketing.list_server_transfers where former_list_server = \"$this_ip\" AND transfer_status = 'not_processed' LIMIT 1" -u admin --password=spiedlen -h 216.66.17.201`
echo "AccountID=" $AccountID
Account=`echo $AccountID | grep -o "[^ a-zA-Z]*$"`

old_list_server=`mysql -e "select AccountID from emarketing.list_server_transfers where former_list_server = \"$this_ip\" AND transfer_status = 'not_processed' LIMIT 1" -u admin --password=spiedlen -h 216.66.17.201`

-- sudo rsync -avz -e ssh /var/lib/mysql/d6593  216.66.17.187:/var/lib/mysql/






This is how to write the main body of the trigger for list server changes in the admin section. Just need to figure out if I can have the trigger run a shell command to rsync the datafiles over to the new server.

DELIMITER $

DROP TRIGGER /*!50032 IF EXISTS */ `CHANGEEMP`$

CREATE TRIGGER `CHANGEEMP` AFTER UPDATE on `EMP`
FOR EACH ROW BEGIN
IF NEW.salary != OLD.salary THEN
INSERT INTO tempSalary (Salary) VALUES (NEW.salary);
END IF;
END$

DELIMITER ;

This is how to write the main body of the trigger for list server changes in the admin section. Just need to figure out if I can have the trigger run a shell command to rsync the datafiles over to the new server.



THROW ERROR in MYSQL
I recommend that you implement and emulation of SQL's SIGNAL, which is supposed forthcoming in future MySQL implementation. 

Implement your emulation by inserting your application defined error message twice into a table of your own design which has a primary key on the msg. The second insert will generate a SQL error. Which you can then catch. If you prefix your error msg with some constant string (i.e. "SIGNAL:"), then when you catch the duplicate key insert error you can parse the message and see that it really is your emulated SIGNAL. 

Don't implement this using dynamic SQL if you're tempted. It is disallowed from within triggers. 



RUN SHELL SCRIPT FROM TRIGGER

You can't really do it but you can create a cron job that checks for something. The trigger itself CAN write to a file like this...

select "To: email@address.se","From: triggers@mysql","Subject: Trigger","","Hallo World" 
into outfile "/inetpub/mailroot/pickup/mail.txt" 
fields terminated by '\r\n';

The cron would then run whatever you output to the file... This could take care of changing list servers ip addresses with about one minute of lag time.



USER DEFINED VARIABLES IN TRIGGERS

SELECT COUNT(*) INTO @rowCount 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'NMS' 
AND TABLE_NAME = 'server'; 

IF (@rowCount > 0) 
THEN 
... 
END IF;


TRIGGER UPDATING TABLE IN DIFFERENT DB

DELIMITER $

DROP TRIGGER `database1`.`trgtest`$

CREATE TRIGGER `database1`.`trgtest` AFTER INSERT on `database1`.`mbt`
FOR EACH ROW
BEGIN
UPDATE database2.t1 SET description = NEW.description WHERE id = NEW.id;
END$

DELIMITER ;


