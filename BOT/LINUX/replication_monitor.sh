#!/bin/bash

#This shell script should be copied into an appropriate location so as to be accessible from all of the database servers.
#A cron job should be installed that runs about every five minutes.
#This shell script will then send an email to anyone we tell it to if replication goes down.
replication_monitor () {
	#if slave_status_query=`/usr/bin/mysql -B --raw --host=localhost -u admin --password=spiedlen -e "show slave status"`
	if slave_status_query=`/usr/bin/mysql -E -s --host=localhost -u admin --password=spiedlen -e "show slave status"`
	then
		slave_status_query2=`echo $slave_status_query | grep -o "Slave_IO_Running: .*"`
		slave_status_query3=`echo $slave_status_query | grep -o "Last_Errno: .*"`

		Slave_IO_Running=`echo $slave_status_query2 | /bin/cut -d' ' -f2`
		Slave_SQL_Running=`echo $slave_status_query2 | /bin/cut -d' ' -f4`

		Last_Errno=`echo $slave_status_query3 | /bin/cut -d' ' -f2`
		LastError=`echo $slave_status_query3 | /bin/cut -d' ' -f4`
		
		Message_String=""
		if [ "No" = "$Slave_IO_Running" ]
		then
			Message_String=$HOSTNAME" REPLICATION ERROR "$LastError
		fi

		if [ "No" = "$Slave_SQL_Running" ]
		then
			Message_String=$HOSTNAME" REPLICATION ERROR "$LastError
		fi

		echo $Message_String

		if [ "" = "$Message_String" ]
		then
			echo "do nothing"
		else
			#send an email or a text message to suppot person containing error string
			echo "$Message_String" | /usr/bin/mutt -s "REPLICATION FAIL" dave@contactmaverick.com ej@contactmaverick.com rob@contactmaverick.com
			#########################################################################
		fi
	else
		echo "failed retreival of slave status"
	fi
	

}

replication_monitor 

