#!/bin/bash
#`which mysql` -u admin -pspiedlen -h ls21 -e "show tables from d7609"
if get_tables_query = `/usr/bin/mysql -u admin --password=spiedlen -h ls21 -e "select tableid, listname from emarketing.lists where accountid = 7609 and list_removed = 0"`







#!/bin/bash
#rsync used master, good, and oc tables from ls01 to ls13
#this file should be run from the dedicated data munging server; the server that operates on all the data, not the list server.


#call this function with the arguments AccountID, ListServer
#example: client_flow    7613     67.217.39.101

#define function
client_flow () { 

	app="67.217.39.98"
	AccountID=$1
	echo "AccountID = $AccountID "
	ListServer=$2
	echo "ListServer = $ListServer "
	if test "" = "$ListServer"
	then
		if get_listserver_query=`/usr/bin/mysql -e "select ListServer from emarketing.settings where AccountID = $AccountID" -u admin --password=spiedlen -h $app`
		then
			lscount=2
			ListServer=`echo $get_listserver_query | /bin/cut -d' ' -f$lscount`
		else
			echo "failure looking up list server /usr/bin/mysql -e \"select ListServer from emarketing.settings where AccountID = $dAccountID\""
		fi
	fi

	if test "" = "$ListServer"
	then
		echo "ListServer = $ListServer "
		return
	else
		echo "ListServer = $ListServer "
	fi
#	store the TableIDs here
	in_holder=""
	for_holder=""


#	select the table ids out of datastore.client_flow
	if prelim_data=`/usr/bin/mysql -e "select substr(list_name, instr(list_name, '.')+1) as list_name from datastore.client_flow where AccountID = $AccountID" -u admin --password=spiedlen`
	then
		if test "" = "$prelim_data"
		then
#			no entries from datastore.client_flow to be processed. still need to create tables and then rsync them over 
			echo "prelim_data variable was empty. Nothing to be done. "
		else
			counter=2
			TableID=`echo $prelim_data | /bin/cut -d' ' -f$counter`
			until test "" = "$TableID"
			do
				echo "TableID = $TableID"
#				rsync the used tables back over from the list server
				echo "/usr/bin/rsync -avz -e /usr/bin/ssh $ListServer:/var/lib/mysql/d$AccountID/$TableID.* /var/lib/mysql/d$AccountID/"
				if rsynced=`/usr/bin/rsync -avz -e /usr/bin/ssh $ListServer:/var/lib/mysql/d$AccountID/$TableID.* /var/lib/mysql/d$AccountID/`
				then
					in_holder=$in_holder"\"$TableID\","
					for_holder=$for_holder"$TableID "
				else
					echo "rsync failed : $ListServer:/var/lib/mysql/d$AccountID/$TableID.* /var/lib/mysql/d$AccountID/"
				fi
#				increment the counter each time we grab another field from the sql results
				let "counter = counter + 1"
				TableID=`echo $prelim_data | /bin/cut -d' ' -f$counter`
			done
		fi
	else
		echo "Preliminary data aquisition failed. "
	fi 




#			call the stored procedure
	echo "Beginning call to client_flow SPROC"
	if sproc=`/usr/bin/mysql -e "call datastore.client_flow($AccountID)" -u admin --password=spiedlen `
	then
		echo "completed call to client_floe SPROC: /usr/bin/mysql -e \"call datastore.client_flow($AccountID)\" -u admin --password=spiedlen"
	else
		echo "call to datastore.client_flow sproc failed: /usr/bin/mysql -e \"call datastore.client_flow($AccountID)\" -u admin --password=spiedlen"
	fi

#			remove the old table entries from app:emarketing.lists
#			This is DANGEROUS! be careful testing this shit
#			remove_old_entries=`/usr/bin/mysql -e "delete from emarketing.lists where AccountID = $AccountID and TableID in($in_holder)" -u admin --password=spiedlen -h $app`
#			this is for testing only
	if test "" = "$in_holder"
	then
		echo "nothing in inholder "
	else
#		get rid of that last comma
		in_holder=`echo $in_holder | sed -e 's/,$//'`
#FIXME $ListServer variable below needs to be $app when this is production ready
#		if remove_old_entries=`/usr/bin/mysql -e "delete from emarketing.lists where AccountID = $AccountID and TableID in($in_holder)" -u admin --password=spiedlen -h $ListServer`
		if remove_old_entries=`/usr/bin/mysql -e "delete from emarketing.lists where AccountID = $AccountID and TableID in($in_holder)" -u admin --password=spiedlen -h $app`
		then
			echo "/usr/bin/mysql -e \"delete from emarketing.lists where AccountID = $AccountID and TableID in($in_holder)\" -u admin --password=spiedlen -h $app"
		else
			echo "failure removing old entries from emarketing.lists: /usr/bin/mysql -e \"delete from emarketing.lists where AccountID = $AccountID and TableID in($in_holder)\" -u admin --password=spiedlen -h $app"
		fi
	fi


#			remove the old tables from the list server
	for for_held in $for_holder; do
		echo "/usr/bin/ssh $ListServer \"rm -rf /var/lib/mysql/d$AccountID/$for_held.*\" "
		if rm_remote_tables=`/usr/bin/ssh $ListServer "rm -rf /var/lib/mysql/d$AccountID/$for_held.*" `
		then
			table_removal_succeeded=1 ;
		else
			echo "removal of remote tables has failed: rm -rf /var/lib/mysql/d$AccountID/$for_held.*"
		fi
	done


#			rsync new tables over to list server
	echo "/usr/bin/mysql -e \"select substr(list_name, instr(list_name, '.')+1) as list_name, records from datastore.client_flow where AccountID = $AccountID\" -u admin --password=spiedlen"
	if rsync_data=`/usr/bin/mysql -e "select substr(list_name, instr(list_name, '.')+1) as list_name, records from datastore.client_flow where AccountID = $AccountID" -u admin --password=spiedlen `
	then
		if test "$rsync_data" = ""
		then
			echo "rsync_data variable was empty. Nothing to be done. "
		else
			rsync_counter=3
			rsync_TableID=`echo $rsync_data | /bin/cut -d' ' -f$rsync_counter`
			until test "" = "$rsync_TableID"
			do
				echo "rsync_TableID = $rsync_TableID"
				#increment the counter each time we grab another field from the sql results
				let "rsync_counter = rsync_counter + 1"
				records=`echo $rsync_data | /bin/cut -d' ' -f$rsync_counter`
				echo "records = $records"
#						drop any new master, good, and oc tables on ls13 from datastore.client_flow that have 0 records
				if [ "$records" -eq 0 ]
				then
					echo "/usr/bin/mysql -e \"drop table d$AccountID.$rsync_TableID\" -u admin --password=spiedlen"
					if drop_zero_table=`/usr/bin/mysql -e "drop table d$AccountID.$rsync_TableID" -u admin --password=spiedlen`
					then
						zero_table_dropped=1
#						delete entries from datastore.client_flow that have 0 records
						echo "/usr/bin/mysql -e \"delete from datastore.client_flow where records = 0 and AccountID = $AccountID and list_name = \"d$AccountID.$rsync_TableID\"\" -u admin --password=spiedlen"
						if delete_zero_table_entry=`/usr/bin/mysql -e "delete from datastore.client_flow where records = 0 and AccountID = $AccountID and list_name = \"d$AccountID.$rsync_TableID\"" -u admin --password=spiedlen`
						then
							delete_zero_table_result=1
						else
							echo "failure deleting datastore.client_flow zero records entry"
						fi
					else
						echo "error dropping zero table: drop table d$AccountID.$rsync_TableID"
					fi
				else
#					rsync the new tables over to the list server
					echo "/usr/bin/rsync -avz -e /usr/bin/ssh /var/lib/mysql/d$AccountID/$rsync_TableID.* $ListServer:/var/lib/mysql/d$AccountID/"
					if new_rsynced=`/usr/bin/rsync -avz -e /usr/bin/ssh /var/lib/mysql/d$AccountID/$rsync_TableID.* $ListServer:/var/lib/mysql/d$AccountID/`
					then
#						create new entries in app:emarketing.lists for the new lists
						echo "/usr/bin/mysql -e \"insert into emarketing.lists (AccountID,TableID,ListName,ListType,Status,total,private,num_loaded,protected) values($AccountID,\"$rsync_TableID\",\"$rsync_TableID\",\"Email\",\"Complete\",$records,1,$records,1)\" -u admin --password=spiedlen -h $app"
#FIXME $ListServer variable below needs to be changed to $app when this is production ready
#						if insert_table_record=`/usr/bin/mysql -e "insert into emarketing.lists (AccountID,TableID,ListName,ListType,Status,total,private,num_loaded,protected) values($AccountID, \"$rsync_TableID\", \"$rsync_TableID\", \"Email\", \"Complete\", $records, 1, $records, 1)" -u admin --password=spiedlen -h $ListServer`
						if insert_table_record=`/usr/bin/mysql -e "insert into emarketing.lists (AccountID,TableID,ListName,ListType,Status,total,private,num_loaded,protected) values($AccountID, \"$rsync_TableID\", \"$rsync_TableID\", \"Email\", \"Complete\", $records, 1, $records, 1)" -u admin --password=spiedlen -h $app`
						then
							new_table_inserted=1
						else
							echo "emarketing.lists insert failed: insert into emarketing.lists (AccountID,TableID,ListName,ListType,Status,total,private,num_loaded,protected) values($AccountID,\"$rsync_TableID\",\"$rsync_TableID\",\"Email\",\"Complete\",$records,1,$records,1)"
						fi
					else
						echo "rsync failed : $ListServer:/var/lib/mysql/d$AccountID/$rsync_TableID.* /var/lib/mysql/d$AccountID/"
					fi
				fi
				#increment the counter each time we grab another field from the sql results
				let "rsync_counter = rsync_counter + 1"
				rsync_TableID=`echo $rsync_data | /bin/cut -d' ' -f$rsync_counter`
			done
		fi
	else
		echo "rsync data select statement failed"
	fi
}


#dAccountID=7613
#dListServer="67.217.39.101"

#client_flow $dAccountID $dListServer > /expedite/logs/derrick/log_file
