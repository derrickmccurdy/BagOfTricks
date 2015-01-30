#!/bin/bash
# This script is run from a cron once per minute on each of the list servers.
# It grabs any unprocessed account additions and creates the account databases and unsubscribe tables.
#get this server's IP address
#this_ip=`/sbin/ifconfig -a | /bin/grep -o "ddr:216.66.74.[^ ]*" | /bin/grep -o "216.66.74.[^ ]*"`
this_ip=`/sbin/ifconfig -a | /bin/grep -o "ddr:216.66.74.[^ ]*\|ddr:67.217.39.[^ ]*" | /bin/grep -o "216.66.74.[^ ]*\|67.217.39.[^ ]*"`
#/sbin/ifconfig -a | /bin/grep -o -e "ddr:216.66.74.[^ ]*\|ddr:67.217.39.[^ ]*"
/bin/echo `/bin/date` >> /tmp/00ListServerAddAccountLog.txt
/bin/echo "

this_ip = $this_ip" >> /tmp/00ListServerAddAccountLog.txt 
/bin/echo $this_ip
prelim_data=`/usr/bin/mysql -e "select ListServer, AccountID  from emarketing.settings where ListServer = \"$this_ip\" AND setup_status = 'not_processed'" -u admin --password=spiedlen -h 67.217.39.98`

if test "$prelim_data" = ""
then
	echo "prelim_data variable was empty. Nothing to be done. " >> /tmp/00ListServerAddAccountLog.txt
	exit
else
	/bin/echo `date` >> /tmp/00ListServerAddAccountLog.txt
fi

counter=3
temp=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
/bin/echo $temp >> /tmp/00ListServerAddAccountLog.txt
until test "$temp" = ""
do
	ListServer=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	let "counter = counter + 1"
	/bin/echo "
	list server = $ListServer" >> /tmp/00ListServerAddAccountLog.txt

	AccountID=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	let "counter = counter + 1"
	/bin/echo "
	account id = $AccountID" >> /tmp/00ListServerAddAccountLog.txt

	#set the status to in progress so no other process grabs it.
	/usr/bin/mysql -e "update emarketing.settings set setup_status = \"in_progress\" where AccountID = $AccountID"  -u admin --password=spiedlen -h 67.217.39.98

	/bin/echo "
	dbresult=/usr/bin/mysql -e \"create database d$AccountID\" -u admin -h  $ListServer --password= " >> /tmp/00ListServerXferLog.txt
	if dbresult=`/usr/bin/mysql -e "create database d$AccountID" -u admin -h  $ListServer --password=spiedlen   2>&1`
	then
		/bin/echo "
		DATABASE CREATION SUCCEEDED" >> /tmp/00ListServerAddAccountLog.txt
		/bin/echo "
		tableresult=/usr/bin/mysql -e \"create table d$AccountID.unsubscribe like template.unsubscribe\" -u admin -h  $ListServer --password= " >> /tmp/00ListServerXferLog.txt
		if tableresult=`/usr/bin/mysql -e "create table d$AccountID.unsubscribe like template.unsubscribe" -u admin -h  $ListServer --password=spiedlen   2>&1`
		then
			/bin/echo "
			TABLE CREATION SUCCEEDED" >> /tmp/00ListServerAddAccountLog.txt
			/usr/bin/mysql -e "update emarketing.settings set setup_status = \"completed\" where AccountID = $AccountID"  -u admin --password=spiedlen -h 67.217.39.98
		else
			/bin/echo "
			TABLE CREATION FAILED" >> /tmp/00ListServerAddAccountLog.txt
			#/usr/bin/mysql -e "update emarketing.settings set setup_status = \"failed\" where AccountID = $AccountID"  -u admin --password=spiedlen -h 216.66.74.103
			/usr/bin/mysql -e "update emarketing.settings set setup_status = \"failed\" where AccountID = $AccountID"  -u admin --password=spiedlen -h 67.217.39.98
		fi
		

	else
		/bin/echo "
		DATABASE CREATION FAILED" >> /tmp/00ListServerAddAccountLog.txt
		/usr/bin/mysql -e "update emarketing.settings set setup_status = \"failed\" where AccountID = $AccountID"  -u admin --password=spiedlen -h 67.217.39.98
	fi
	temp=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
done

