#!/bin/bash
# This script is run from a cron once per day.
# It sends the disk usage statistics of whatever partition /var/lib/mysql is on to the master database server and puts them in the table datastore.disk_usage.
#get this server's IP address
#216.66.75.240
server=`/sbin/ifconfig -a | /bin/grep -o "ddr:216.66.75.[^ ]*\|ddr:216.66.74.[^ ]*\|ddr:67.217.39.[^ ]*\|ddr:66.151.5.[^ ]*" | /bin/grep -o "216.66.75.[^ ]*\|66.151.5.[^ ]*\|216.66.74.[^ ]*\|67.217.39.[^ ]*"`
#/sbin/ifconfig -a | /bin/grep -o -e "ddr:216.66.74.[^ ]*\|ddr:67.217.39.[^ ]*"
/bin/echo `/bin/date` >> /tmp/00ListServerDiskUsageLog.txt
#| id        | int(10)     | NO   | PRI | NULL    | auto_increment | 
#| server    | varchar(20) | NO   |     | NULL    |                | 
#| available | varchar(10) | NO   |     | NULL    |                | 
#| used      | varchar(10) | NO   |     | NULL    |                | 

/bin/echo "
this_ip = $server" >> /tmp/00ListServerDiskUsageLog.txt 
/bin/echo $server
#this_ip=216.66.17.229
#available=`/bin/df --si /var/lib/mysql > /tmp/free; /usr/bin/tail -1 /tmp/free | /bin/sed -r -e 's/ +/\t/g' | /bin/cut -f4`
available=`/bin/df -h /var/lib/mysql > /tmp/free; /usr/bin/tail -1 /tmp/free | /bin/sed -r -e 's/ +/\t/g' | /bin/cut -f4`
#used=`/bin/df --si /var/lib/mysql > /tmp/free; /usr/bin/tail -1 /tmp/free | /bin/sed -r -e 's/ +/\t/g' | /bin/cut -f5`
used=`/bin/df -h /var/lib/mysql > /tmp/free; /usr/bin/tail -1 /tmp/free | /bin/sed -r -e 's/ +/\t/g' | /bin/cut -f5`
total_size=`/bin/df -h /var/lib/mysql > /tmp/free; /usr/bin/tail -1 /tmp/free | /bin/sed -r -e 's/ +/\t/g' | /bin/cut -f2`
prelim_data=`/usr/bin/mysql -e "insert into datastore.disk_space (server, available, used, total_space) value(\"$server\",\"$available\",\"$used\",\"$total_size\") " -u admin --password=spiedlen -h 67.217.39.105`

if test "$prelim_data" = ""
then
	/bin/echo "prelim_data variable was empty. FAIL. " >> /tmp/00ListServerDiskUsageLog.txt
	exit
else
	/bin/echo `date` >> /tmp/00ListServerDiskUsageLog.txt
fi
