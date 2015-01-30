#!/bin/bash
# This script is run from a cron once per hour from the "main app server".
# It grabs all the list server transfer records older than 30 days old where the current list server is NOT the same as the OLD list server and drops the database from the old list server IF the current list server is not the same as the old list server.

#if prelim_data=`/usr/bin/mysql -e "select s.AccountID as AccountID, t.former_list_server as former_list_server, t.id AS id  from emarketing.list_server_transfers t INNER JOIN emarketing.settings s ON t.AccountID = s.AccountID where t.transfer_status = \"completed\" AND t.former_list_server != s.ListServer AND date_added > DATE_SUB(NOW(), INTERVAL 40 DAY)   AND date_added < DATE_SUB(NOW(), INTERVAL 30 DAY)  AND old_copy_deleted  IS NULL LIMIT 1" -u admin --password=spiedlen -h 216.66.17.201`
/bin/echo `date` >> /tmp/00ListServerXferCleanuplog.txt

if prelim_data=`/usr/bin/mysql -e "select s.AccountID as AccountID, t.former_list_server as former_list_server, t.id AS id  from emarketing.list_server_transfers t INNER JOIN emarketing.settings s ON t.AccountID = s.AccountID where t.transfer_status = \"completed\" AND t.former_list_server != s.ListServer AND date_added > DATE_SUB(NOW(), INTERVAL 1 DAY) AND old_copy_deleted  IS NULL " -u admin --password=spiedlen -h 67.217.39.98`
then
        if /usr/bin/test "$prelim_data" = ""
        then
                /bin/echo "prelim_data variable was empty. Nothing to be done. " >> /tmp/00ListServerXferCleanuplog.txt
                exit
        fi

	#set the initial counter variable value to the first field in the results return that contains actual data
	counter=4
	#set the initial temp variable value to the data of the first sql results return that is actual data
	temp=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	#do this stuff until there are no more fields in the sql results
        until /usr/bin/test "$temp" = ""
        do
		/bin/echo "prelim_data = $prelim_data " >> /tmp/00ListServerXferCleanuplog.txt
		AccountID=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		#increment the counter each time we grab another field from the sql results
		let "counter = counter + 1"
		/bin/echo "AccountID = $AccountID" >> /tmp/00ListServerXferCleanuplog.txt
		former_list_server=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		#increment the counter each time we grab another field from the sql results
		let "counter = counter + 1"
		/bin/echo "former_list_server = $former_list_server" >> /tmp/00ListServerXferCleanuplog.txt
		id=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		#increment the counter each time we grab another field from the sql results
		let "counter = counter + 1"
		/bin/echo "id = $id" >> /tmp/00ListServerXferCleanuplog.txt
#		using mysql commands to drop the DB WILL replicate to the slaves. If the db was moved to a slave from its master, the drop db command will remove it from the slave as well as the master.
#		/bin/echo "/usr/bin/mysql -e \"DROP DATABASE d$AccountID\" -u admin --password=spiedlen -h $former_list_server" >> /tmp/00ListServerXferCleanuplog.txt
#		so we will use the shell instead.
		/bin/echo "/usr/bin/ssh  \"rm -rf /var/lib/mysql/d$AccountID\" $former_list_server" >> /tmp/00ListServerXferCleanuplog.txt
		#exit
#		if drop_command=`/usr/bin/mysql -e "DROP DATABASE d$AccountID" -u admin --password=spiedlen -h $former_list_server`
		if drop_command=`/usr/bin/ssh $former_list_server "rm -rf /var/lib/mysql/d$AccountID/" `
		then
			/bin/echo "data base d$AccountID removed successfully from $former_list_server" >> /tmp/00ListServerXferCleanuplog.txt
			if update_xfer_table_command=`/usr/bin/mysql -e "UPDATE emarketing.list_server_transfers SET old_copy_deleted = NOW() WHERE id = $id" -u admin --password=spiedlen -h 67.217.39.98`
			then
				/bin/echo "emarketing.list_server_transfer.old_copy_deleted successfully updated to current date." >> /tmp/00ListServerXferCleanuplog.txt
			else
				/bin/echo "EMARKETING.LIST_SERVER_TRANSFER.OLD_COPY_DELETED UPDATE TO CURRENT DATE FOR ID $id FAILED." >> /tmp/00ListServerXferCleanuplog.txt
			fi
		else
			/bin/echo "DROP DATABASE d$AccountID FAILED" >> /tmp/00ListServerXferCleanuplog.txt
		fi
		#set the temp variable equal to the next sql result field
		temp=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	done
else
        /bin/echo "PRELIM_DATA VARIABLE WAS EMPTY" >> /tmp/00ListServerXferCleanuplog.txt
        exit
fi
