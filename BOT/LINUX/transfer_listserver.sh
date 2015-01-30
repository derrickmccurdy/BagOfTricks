#!/bin/bash
# This script is run from a cron once per minute ON the "former list server".
# It grabs one list server transfer request per minute.
# It attempts to transfer the datafiles to the new listserver.
#get this server's IP address
#this_ip=`/sbin/ifconfig -a | /bin/grep -o "ddr:216.66.74.[^ ]*" | /bin/grep -o "216.66.74.[^ ]*"`
this_ip=`/sbin/ifconfig -a | /bin/grep -o "ddr:216.66.74.[^ ]*\|ddr:67.217.39.[^ ]*" | /bin/grep -o "216.66.74.[^ ]*\|67.217.39.[^ ]*"`
#/sbin/ifconfig -a | /bin/grep -o -e "ddr:216.66.74.[^ ]*\|ddr:67.217.39.[^ ]*"
/bin/echo `/bin/date` >> /tmp/00ListServerXferLog.txt
/bin/echo "

this_ip = $this_ip" >> /tmp/00ListServerXferLog.txt 
/bin/echo $this_ip
#this_ip=216.66.17.229
prelim_data=`/usr/bin/mysql -e "select id, former_list_server, new_list_server, AccountID  from emarketing.list_server_transfers where former_list_server = \"$this_ip\" AND transfer_status = 'not_processed'" -u admin --password=spiedlen -h 67.217.39.98`

if test "$prelim_data" = ""
then
	echo "prelim_data variable was empty. Nothing to be done. " >> /tmp/00ListServerXferLog.txt
	exit
else
	/bin/echo `date` >> /tmp/00ListServerXferLog.txt
fi

#id former_list_server new_list_server AccountID transfer_status date_added old_copy_deleted 752 216.66.17.229 216.66.17.191 6975 not_processed 2008-12-03 10:32:21 NULL
#/bin/echo $prelim_data
#exit


counter=5
temp=`echo $prelim_data | /bin/cut -d' ' -f$counter`
until test "$temp" = ""
do
	id=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	let "counter = counter + 1"
	/bin/echo "
	id = $id" >> /tmp/00ListServerXferLog.txt

	former_list_server=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	let "counter = counter + 1"
	/bin/echo "
	former list server = $former_list_server" >> /tmp/00ListServerXferLog.txt

	new_list_server=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	let "counter = counter + 1"
	/bin/echo "
	New list server = $new_list_server" >> /tmp/00ListServerXferLog.txt

	AccountID=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	let "counter = counter + 1"
	/bin/echo "
	AccountID = $AccountID" >> /tmp/00ListServerXferLog.txt

	#set the status to in progress so no other process grabs it and tries to transfer it.
	/usr/bin/mysql -e "update emarketing.list_server_transfers set transfer_status = \"in_progress\" where id = $id"  -u admin --password=spiedlen -h 67.217.39.98

	#Need to make sure that this file has all the right hosts in it to prevent being prompted as below. /home01/derrick/.ssh/known_hosts
	#The authenticity of host '216.66.17.197 (216.66.17.197)' can't be established.
	#RSA key fingerprint is 5a:b7:ad:69:0c:6e:04:3d:45:db:33:2e:f4:09:a0:9e.
	#Are you sure you want to continue connecting (yes/no)? yes
	#Warning: Permanently added '216.66.17.197' (RSA) to the list of known hosts.
	/bin/echo "
	result=/usr/bin/sudo /usr/bin/rsync -q -avz -e /usr/bin/ssh /var/lib/mysql/d$AccountID  $new_list_server:/var/lib/mysql/ " >> /tmp/00ListServerXferLog.txt
	if result=`/usr/bin/rsync -q -avz -e /usr/bin/ssh /var/lib/mysql/d$AccountID  $new_list_server:/var/lib/mysql/  2>&1`
	then
		/bin/echo "
		TRANSFER SUCCEEDED" >> /tmp/00ListServerXferLog.txt
		/usr/bin/mysql -e "update emarketing.list_server_transfers set transfer_status = \"completed\" where id = $id"  -u admin --password=spiedlen -h 67.217.39.98
		#this is where I would delete the datafiles on the old list server.
		#/usr/bin/mysql -e "drop database d{$AccountID} "  -u admin --password=spiedlen -h $former_list_server 

	else
		/bin/echo "
		TRANSFER FAILED" >> /tmp/00ListServerXferLog.txt
		/usr/bin/mysql -e "update emarketing.list_server_transfers set transfer_status = \"failed\" where id = $id"  -u admin --password=spiedlen -h 67.217.39.98
		/usr/bin/mysql -e "update emarketing.settings set ListServer = \"$former_list_server\" where AccountID = $AccountID"  -u admin --password=spiedlen -h 67.217.39.98
		#exit
	fi
	/bin/echo $result >> /tmp/00ListServerXferLog.txt
	temp=`echo $prelim_data | /bin/cut -d' ' -f$counter`
done

