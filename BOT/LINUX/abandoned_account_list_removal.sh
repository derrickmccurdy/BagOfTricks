#!/bin/bash
# This script is run from a cron once per hour from the "main app server".
# It grabs all the list server transfer records older than 30 days old where the current list server is NOT the same as the OLD list server and drops the database from the old list server IF the current list server is not the same as the old list server.
sentinel_account_id=""
sentinel_list_server=""

/bin/echo `date` >> /tmp/00abandoned_account_list_removallog.txt
#if the account has been abandoned for more than 120 days and we have not yet snaffled up the lists into our master data set, too bad.
if prelim_data=`/usr/bin/mysql -e "select l.AccountID as AccountID, s.ListServer as List_server, l.id as listid, l.TableID as TableID from emarketing.lists as l inner join system.accounts as a on l.AccountID = a.AccountID inner join emarketing.settings as s on l.AccountID = s.AccountID where a.AccountEnabled = 0 and a.DateDisabled is not null and a.DateDisabled <> "" and a.DateDisabled < date_sub(current_date, interval 120 day) and l.list_removed = 0 order by l.AccountID"`
then
        if /usr/bin/test "$prelim_data" = ""
        then
                /bin/echo "prelim_data variable was empty. Nothing to be done. " >> /tmp/00abandoned_account_list_removallog.txt
                exit
        fi

	#set the initial counter variable value to the first field in the results return that contains actual data
	counter=5
	#set the initial temp variable value to the data of the first sql results return that is actual data
	temp=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	#do this stuff until there are no more fields in the sql results
        until /usr/bin/test "$temp" = ""
        do
		/bin/echo "prelim_data = $prelim_data " >> /tmp/00abandoned_account_list_removallog.txt
		AccountID=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		#increment the counter each time we grab another field from the sql results
		let "counter = counter + 1"
		/bin/echo "AccountID = $AccountID" >> /tmp/00abandoned_account_list_removallog.txt
		list_server=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		#increment the counter each time we grab another field from the sql results
		let "counter = counter + 1"
		/bin/echo "list_server = $list_server" >> /tmp/00abandoned_account_list_removallog.txt
		id=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		#increment the counter each time we grab another field from the sql results
		let "counter = counter + 1"
		/bin/echo "id = $id" >> /tmp/00abandoned_account_list_removallog.txt
		TableID=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		#increment the counter each time we grab another field from the sql results
		let "counter = counter + 1"
		if /usr/bin/test "$sentinel_account_id" != "$AccountID"
		then
			#get rid of all the rtables for this account
			if drop_command=`/usr/bin/ssh $sentinel_list_server "rm -f /var/lib/mysql/d$sentinel_account_id/r$sentinel_account_id_*.*" `
			then
				/bin/echo "Temp tables from account d$AccountID removed successfully from $list_server" >> /tmp/00abandoned_account_list_removallog.txt
			else
				/bin/echo "ABANDONED ACCOUNT TEMP TABLE REMOVAL d$AccountID.$TableID FAILED" >> /tmp/00abandoned_account_list_removallog.txt
			fi
			if /usr/bin/test "$sentinel_account_id" != ""
			then
				#get rid of all tables left over from the previous $sentinel_account_id that might not have gotten deleted such as temp "r" tables or any others that were not listed in emarketing.lists
				#if drop_command=`/usr/bin/ssh $sentinel_list_server "rm -f /var/lib/mysql/d$sentinel_account_id/t$sentinel_account_id_*.*" `
				#list all files except for db.opt and unsubscribe.*; pipe to xargs for removal
				if drop_command=`/usr/bin/ssh $sentinel_list_server "ls -I "unsubscribe.*" -I "db.*" /var/lib/mysql/d$sentinel_account_id/ | xargs -i rm -f /var/lib/mysql/d$sentinel_account_id/'{}'" `
				then
					/bin/echo "Superfluous tables from account d$sentinel_account_id removed successfully from $sentinel_list_server" >> /tmp/00abandoned_account_list_removallog.txt
				else
					/bin/echo "SUPERFLUOUS TABLE REMOVAL FROM d$sentinel_account_id FAILED" >> /tmp/00abandoned_account_list_removallog.txt
				fi
			fi
			#set the sentinel_account_id = $AccountID and sentinel_list_server = $list_server so we do not attempt these steps more than once per Account
			sentinel_account_id=$AccountID
			sentinel_list_server=$list_server
		fi
		/bin/echo "TableID = $TableID" >> /tmp/00abandoned_account_list_removallog.txt
		/bin/echo "/usr/bin/ssh  \"rm -f /var/lib/mysql/d$AccountID/$TableID.*\" $list_server" >> /tmp/00abandoned_account_list_removallog.txt
		#exit
		if drop_command=`/usr/bin/ssh $list_server "rm -f /var/lib/mysql/d$AccountID/$TableID.*" `
		then
			/bin/echo "abandoned account table d$AccountID.$TableID removed successfully from $list_server" >> /tmp/00abandoned_account_list_removallog.txt
			#if update_xfer_table_command=`/usr/bin/mysql -e "UPDATE emarketing.lists SET table_removed = 1 WHERE id = $id" -u admin --password=spiedlen -h 67.217.39.98`
			if list_deletion_log_insert_command=`/usr/bin/mysql -e "insert into emarketing.list_deletion_log (user_id, AccountID, ListName, TableID, list_id, ip) values(1,$AccountID, \"Abandoned Account List\",\"$TableID\",$id,\"127.0.0.1\") " -u admin --password=spiedlen -h 67.217.39.98`
			then
				/bin/echo "emarketing.lists successfully updated to show list as removed." >> /tmp/00abandoned_account_list_removallog.txt
			else
				/bin/echo "EMARKETING.LISTS UPDATE LIST_REMOVED TO 1 FOR ID $id FAILED." >> /tmp/00abandoned_account_list_removallog.txt
			fi
		else
			/bin/echo "ABANDONED LEASED LIST TALBE REMOVAL d$AccountID.$TableID FAILED" >> /tmp/00abandoned_account_list_removallog.txt
		fi
		#set the temp variable equal to the next sql result field
		temp=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	done
else
        /bin/echo "PRELIM_DATA VARIABLE WAS EMPTY" >> /tmp/00abandoned_account_list_removallog.txt
        exit
fi
