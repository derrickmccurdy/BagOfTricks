#!/bin/bash
#rsync used master, good, and oc tables from ls01 to ls13
#this file should be run from the dedicated data munging server; the server that operates on all the data, not the list server.


#call this function with the arguments AccountID, ListServer
#example: client_flow    7613     67.217.39.101

#define function
client_flow () { 

	AccountID=$1
	echo "AccountID = $AccountID "
	ListServer=$2
	echo "ListServer = $ListServer "
#	store the TableIDs here
	in_holder=""
	for_holder=""

	app="67.217.39.98"

#	select the table ids out of datastore.client_flow
	if prelim_data=`/usr/bin/mysql -e "select substr(list_name, instr(list_name, '.')+1) as list_name from datastore.client_flow where AccountID = $AccountID" -u admin --password=spiedlen `
	then
		if test $prelim_data = ""
		then
			echo "prelim_data variable was empty. Nothing to be done. "
			exit
		else
			counter=2
			temp=`echo $prelim_data | /bin/cut -d' ' -f$counter`
			until test "$temp" = ""
			do
				TableID=`echo $prelim_data | /bin/cut -d' ' -f$counter`
				echo $TableID
#				increment the counter each time we grab another field from the sql results
				let "counter = counter + 1"
#				rsync the used tables back over from the list server
#testing				if rsynced=`/usr/bin/rsync -avz -e ssh $ListServer:/var/lib/mysql/d$AccountID/$TableID.* /var/lib/mysql/d$AccountID/`
				if rsynced=`echo "/usr/bin/rsync -avz -e ssh $ListServer:/var/lib/mysql/d$AccountID/$TableID.* /var/lib/mysql/d$AccountID/"`
				then
					in_holder=$in_holder"\"$TableID\","
					for_holder=$for_holder"$TableID "
				else
					echo "rsync failed : $ListServer:/var/lib/mysql/d$AccountID/$TableID.* /var/lib/mysql/d$AccountID/"
				fi
			done

#			call the stored procedure
#FIXME			go ahead and put this in an if statement.
			echo "Beginning call to client_flow SPROC"
#testing			sproc=`/usr/bin/mysql -e "call datastore.client_flow($AccountID)" -u admin --password=spiedlen `
			sproc="/usr/bin/mysql -e \"call datastore.client_flow($AccountID)\" -u admin --password=spiedlen "
			echo $sproc

#			remove the old table entries from app:emarketing.lists
#FIXME			this also needs to be put in an if statement
#			This is DANGEROUS! be careful testing this shit
#			remove_old_entries=`/usr/bin/mysql -e "delete from emarketing.lists where AccountID = $AccountID and TableID in($in_holder)" -u admin --password=spiedlen -h $app`
#			this is for testing only
#testing			remove_old_entries=`/usr/bin/mysql -e "delete from emarketing.lists where AccountID = $AccountID and TableID in($in_holder)" -u admin --password=spiedlen -h $ListServer`
			remove_old_entries=`echo "/usr/bin/mysql -e \"delete from emarketing.lists where AccountID = $AccountID and TableID in($in_holder)\" -u admin --password=spiedlen -h $ListServer"`


#			remove the old tables from the list server
			for for_held in $for_holder; do
#testing				if rm_remote_tables=`/usr/bin/ssh "rm -rf /var/lib/mysql/d$AccountID/$for_held.*" $ListServer`
				if rm_remote_tables=`echo "/usr/bin/ssh \"rm -rf /var/lib/mysql/d$AccountID/$for_held.*\" $ListServer"`
				then
					table_removal_succeeded=1 ;
				else
					echo "removal of remote tables has failed: rm -rf /var/lib/mysql/d$AccountID/$for_held.*"
				fi
			done


#			rsync new tables over to list server
			if rsync_data=`/usr/bin/mysql -e "select substr(list_name, instr(list_name, '.')+1) as list_name, records from datastore.client_flow where AccountID = $AccountID" -u admin --password=spiedlen `
			then
				if test $rsync_data = ""
				then
					echo "rsync_data variable was empty. Nothing to be done. "
					exit
				else
					rsync_counter=2
					rsync_temp=`echo $rsync_data | /bin/cut -d' ' -f$rsync_counter`
					until test "$rsync_temp" = ""
					do
						rsync_TableID=`echo $rsync_data | /bin/cut -d' ' -f$rsync_counter`
						echo "rsync_TableID = $rsync_TableID"
						#increment the counter each time we grab another field from the sql results
						let "rsync_counter = rsync_counter + 1"
						records=`echo $rsync_data | /bin/cut -d' ' -f$rsync_counter`
						echo "records = $records"
						#increment the counter each time we grab another field from the sql results
						let "rsync_counter = rsync_counter + 1"
#						drop any new master, good, and oc tables on ls13 from datastore.client_flow that have 0 records
						if [ "$records" -eq 0 ]
						then
#testing							if drop_zero_table=`/usr/bin/mysql -e "drop table d$AccountID.$TableID" -u admin --password=spiedlen`
							if drop_zero_table=`echo "/usr/bin/mysql -e \"drop table d$AccountID.$TableID\" -u admin --password=spiedlen"`
							then
								zero_table_dropped=1
#								delete entries from datastore.client_flow that have 0 records
#testing								if delete_zero_table_entry=`/usr/bin/mysql -e "delete from datastore.client_flow where records = 0 and AccountID = $AccountID and list_name = \"d$AccountID.$TableID\"" -u admin --password=spiedlen`
								if delete_zero_table_entry=`echo "/usr/bin/mysql -e \"delete from datastore.client_flow where records = 0 and AccountID = $AccountID and list_name = \\"d$AccountID.$TableID\\"\" -u admin --password=spiedlen"`
								then
									delete_zero_table_result=1
								else
									echo "failure deleting datastore.client_flow zero records entry"
								fi
							else
								echo "error dropping zero table: drop table d$AccountID.$TableID"
							fi
						else
#							rsync the used tables back over from the list server
#testing							if new_rsynced=`/usr/bin/rsync -avz -e ssh /var/lib/mysql/d$AccountID/$rsync_TableID.* $ListServer:/var/lib/mysql/d$AccountID/`
							if new_rsynced=`echo "/usr/bin/rsync -avz -e ssh /var/lib/mysql/d$AccountID/$rsync_TableID.* $ListServer:/var/lib/mysql/d$AccountID/"`
							then
#							create new entries in app:emarketing.lists for the new lists
#testing								if insert_table_record=`/usr/bin/mysql -e "insert into emarketing.lists (AccountID,TableID,ListName,ListType,Status,total,private,num_loaded,protected) values($AccountID,\"$TableID\",\"$TableID\",\"Email\",\"Complete\",$records,1,$records,1)" -u admin --password=spiedlen -h $app`
								if insert_table_record=`echo "/usr/bin/mysql -e \"insert into emarketing.lists (AccountID,TableID,ListName,ListType,Status,total,private,num_loaded,protected) values($AccountID,\\"$TableID\\",\\"$TableID\\",\\"Email\\",\\"Complete\\",$records,1,$records,1)\" -u admin --password=spiedlen -h $app"`
								then
									new_table_inserted=1
								else
									echo "emarketing.lists insert failed: insert into emarketing.lists (AccountID,TableID,ListName,ListType,Status,total,private,num_loaded,protected) values($AccountID,\"$TableID\",\"$TableID\",\"Email\",\"Complete\",$records,1,$records,1)"
								fi
							else
								echo "rsync failed : $ListServer:/var/lib/mysql/d$AccountID/$TableID.* /var/lib/mysql/d$AccountID/"
							fi
						fi
					done
				fi
			else
				echo "rsync data select statement failed"
				exit
			fi
		fi
	else
		echo "Preliminary data aquisition failed. "
		exit
	fi 

}


#dAccountID=7613
#dListServer="67.217.39.101"

#client_flow $dAccountID $dListServer > /expedite/logs/derrick/log_file
