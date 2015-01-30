#!/bin/bash
#This script should be run from each of the intermediate masters
#204
#	198
#		195
#		194
#		193
#		229
#	197
#		192
#		191
#		190
#		189
#	196
#		188
#		187
#		186
#		180

#need to copy and alter this script to home01
#. /home/derrick/BOT/SQL/shslave.sh "stop slave"

ips="216.66.17.198
216.66.17.197
216.66.17.196
216.66.17.195
216.66.17.194
216.66.17.193
216.66.17.192
216.66.17.191
216.66.17.189
216.66.17.188
216.66.17.187
216.66.17.186
216.66.17.180
216.66.17.229"

intermediate_ips="216.66.17.198
216.66.17.197
216.66.17.196"

#my_ip=`/sbin/ifconfig -a | grep -o "ddr:216.66.17.[^ ]*" | grep -o "216.66.17.[^ ]*"`
my_ip=`/sbin/ifconfig -a | grep -o "ddr:192.168.0.[^ ]*" | grep -o "192.168.0.[^ ]*"`
echo $my_ip

#if test "$my_ip" = "216.66.17.198"
if test "$my_ip" = "192.168.0.81"
then
	myslaves="216.66.17.195
216.66.17.194
216.66.17.193
216.66.17.229"
elif test "$my_ip" = "216.66.17.197"
then
	myslaves="216.66.17.192
216.66.17.191
216.66.17.189"
elif test "$my_ip" = "216.66.17.196"
then
	myslaves="216.66.17.188
216.66.17.187
216.66.17.186
216.66.17.180"
fi

#get everything for THIS server
/usr/bin/mysql -e "slave stop" -u admin --password=spiedlen 

for ip in $my_slaves
do
	/usr/bin/mysql -e "slave stop" -u admin --password=spiedlen -h $ip
done

masterstatus=`/usr/bin/mysql -e "show master status" -u admin --password=spiedlen -h 216.66.17.204`
masterfile=`echo $masterstatus |  /usr/bin/cut -d' ' -f5`
masterpos=`echo $masterstatus |  /usr/bin/cut -d' ' -f6`


/usr/bin/rsync -avz -e ssh 216.66.17.204:/var/lib/mysql/datastore/tblsuppressiontimes.* /var/lib/mysql/datastore/
/usr/bin/rsync -avz -e ssh 216.66.17.204:/var/lib/mysql/datastore/tblbounces.* $ip:/var/lib/mysql/datastore/
/usr/bin/rsync -avz -e ssh 216.66.17.204:/var/lib/mysql/datastore/*.TRN $ip:/var/lib/mysql/datastore/
/usr/bin/rsync -avz -e ssh 216.66.17.204:/var/lib/mysql/system/tblglobal_* $ip:/var/lib/mysql/system/
/usr/bin/rsync -avz -e ssh 216.66.17.204:/var/lib/mysql/system/*.TRN $ip:/var/lib/mysql/system/
/usr/bin/rsync -avz -e ssh 216.66.17.204:/var/lib/mysql/datastore/tblmaster.* /var/lib/mysql/datastore/



#upload all that data to all of this server's slaves
for ip in $my_slaves
do
	mystatus=`/usr/bin/mysql -e "show master status" -u admin --password=spiedlen
	myfile=`echo $masterstatus |  /usr/bin/cut -d' ' -f5`
	mypos=`echo $masterstatus |  /usr/bin/cut -d' ' -f6`
	/usr/bin/rsync -avz -e ssh /var/lib/mysql/datastore/tblsuppressiontimes.* $ip:/var/lib/mysql/datastore/
	/usr/bin/rsync -avz -e ssh /var/lib/mysql/datastore/tblbounces.* $ip:/var/lib/mysql/datastore/
	/usr/bin/rsync -avz -e ssh /var/lib/mysql/datastore/*.TRN $ip:/var/lib/mysql/datastore/
	/usr/bin/rsync -avz -e ssh /var/lib/mysql/system/tblglobal_* $ip:/var/lib/mysql/system/
	/usr/bin/rsync -avz -e ssh /var/lib/mysql/system/*.TRN $ip:/var/lib/mysql/system/
	/usr/bin/mysql -e "CHANGE MASTER TO MASTER_HOST=\'$my_ip\', MASTER_USER=\'rep1\', MASTER_PASSWORD=\'45t3r15k\', MASTER_LOG_FILE=\'$myfile\', MASTER_LOG_POS=$mypos ;" -u admin --password=spiedlen -h $ip
	/user/bin/mysql -e "flush tables" -u admin --password=spiedlen -h $ip 
	/user/bin/mysql -e "slave start" -u admin --password=spiedlen -h $ip 
done

/usr/bin/mysql -e "CHANGE MASTER TO MASTER_HOST=\'$my_ip\', MASTER_USER=\'rep1\', MASTER_PASSWORD=\'45t3r15k\', MASTER_LOG_FILE=\'$masterfile\', MASTER_LOG_POS=$masterpos ;" -u admin --password=spiedlen 
/user/bin/mysql -e "flush tables" -u admin --password=spiedlen 
/user/bin/mysql -e "slave start" -u admin --password=spiedlen 

