#!/bin/bash
# This script is run from a cron once per hour from the "main app server".
# It grabs all the list server transfer records older than 30 days old where the current list server is NOT the same as the OLD list server and drops the database from the old list server IF the current list server is not the same as the old list server.

#if prelim_data=`/usr/bin/mysql -e "select s.AccountID as AccountID, t.former_list_server as former_list_server, t.id AS id  from emarketing.list_server_transfers t INNER JOIN emarketing.settings s ON t.AccountID = s.AccountID where t.transfer_status = \"completed\" AND t.former_list_server != s.ListServer AND date_added > DATE_SUB(NOW(), INTERVAL 40 DAY)   AND date_added < DATE_SUB(NOW(), INTERVAL 30 DAY)  AND old_copy_deleted  IS NULL LIMIT 1" -u admin --password=spiedlen -h 216.66.17.201`
/bin/echo `date` >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
#if prelim_data=`/usr/bin/mysql -e "select s.AccountID as AccountID, t.former_list_server as former_list_server, t.id AS id  from emarketing.list_server_transfers t INNER JOIN emarketing.settings s ON t.AccountID = s.AccountID where t.transfer_status = \"completed\" AND t.former_list_server != s.ListServer AND date_added > DATE_SUB(NOW(), INTERVAL 1 DAY) AND old_copy_deleted  IS NULL " -u admin --password=spiedlen -h 67.217.39.98`
# select l.ID, l.list_code, l.TableID, s.ListServer, a.AccountID, a.DateDisabled from system.accounts as a inner join emarketing.settings as s on a.AccountID = s.AccountID inner join emarketing.lists as l on a.AccountID = l.AccountID where a.AccountEnabled = 0 and a.DateDisabled is not null and a.DateDisabled <> "" and a.DateDisabled < date_sub(current_date, interval 60 day) and l.list_code <> 0 and l.private = 1 and l.list_removed = 0 ;
if prelim_data=`/usr/bin/mysql -e "select l.AccountID as AccountID, s.ListServer as List_server, l.id as listid, l.TableID as TableID from emarketing.lists as l inner join system.accounts as a on l.AccountID = a.AccountID inner join emarketing.settings as s on l.AccountID = s.AccountID where a.AccountEnabled = 0 and a.DateDisabled is not null and a.DateDisabled <> "" and a.DateDisabled < date_sub(current_date, interval 60 day) and l.list_code <> 0 and l.private = 1 and l.list_removed = 0"`
then
        if /usr/bin/test "$prelim_data" = ""
        then
                /bin/echo "prelim_data variable was empty. Nothing to be done. " >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
                exit
        fi

	#set the initial counter variable value to the first field in the results return that contains actual data
	counter=5
	#set the initial temp variable value to the data of the first sql results return that is actual data
	temp=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	#do this stuff until there are no more fields in the sql results
        until /usr/bin/test "$temp" = ""
        do
		/bin/echo "prelim_data = $prelim_data " >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
		AccountID=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		#increment the counter each time we grab another field from the sql results
		let "counter = counter + 1"
		/bin/echo "AccountID = $AccountID" >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
		list_server=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		#increment the counter each time we grab another field from the sql results
		let "counter = counter + 1"
		/bin/echo "list_server = $list_server" >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
		id=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		#increment the counter each time we grab another field from the sql results
		let "counter = counter + 1"
		/bin/echo "id = $id" >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
		TableID=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		#increment the counter each time we grab another field from the sql results
		let "counter = counter + 1"
		/bin/echo "TableID = $TableID" >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
		/bin/echo "/usr/bin/ssh  \"rm -f /var/lib/mysql/d$AccountID/$TableID.*\" $list_server" >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
		#exit
		if drop_command=`/usr/bin/ssh $list_server "rm -f /var/lib/mysql/d$AccountID/$TableID.*" `
		then
			/bin/echo "data base d$AccountID removed successfully from $list_server" >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
			if update_xfer_table_command=`/usr/bin/mysql -e "UPDATE emarketing.lists SET table_removed = 1 WHERE id = $id" -u admin --password=spiedlen -h 67.217.39.98`
			then
				/bin/echo "emarketing.lists successfully updated to show list as removed." >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
			else
				/bin/echo "EMARKETING.LISTS UPDATE LIST_REMOVED TO 1 FOR ID $id FAILED." >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
			fi
		else
			/bin/echo "ABANDONED LEASED LIST TALBE REMOVAL d$AccountID.$TableID FAILED" >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
		fi
		#set the temp variable equal to the next sql result field
		temp=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	done
else
        /bin/echo "PRELIM_DATA VARIABLE WAS EMPTY" >> /tmp/00abandoned_account_leased_list_cleanuplog.txt
        exit
fi
