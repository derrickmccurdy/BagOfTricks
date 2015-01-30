#!/bin/bash
/bin/echo "Any crashed tblmasters?" > /tmp/morning_report.txt
/home/derrick/BOT/SQL/shslave.sh "select count(*) from datastore.tblmaster " >> /tmp/morning_report.txt
/usr/bin/mysql -e "select * from datastore.record_reports order by id desc limit 30 " -u admin --password=spiedlen -h master >> /tmp/morning_report.txt
/bin/echo "Any servers out of disk space?" >> /tmp/morning_report.txt
#/home/derrick/BOT/LINUX/shslave.sh "df --si /var/lib/mysql" >> /tmp/morning_report.txt
echo "Available		Used" >> /tmp/morning_report.txt
/home/derrick/BOT/LINUX/shslave.sh "df --si /var/lib/mysql > /tmp/free; tail -1 /tmp/free | sed -r -e 's/ +/\t/g' | cut -f4-5" >> /tmp/morning_report.txt
/bin/echo "Any servers clogged with processes?" >> /tmp/morning_report.txt
/home/derrick/BOT/SQL/shslave.sh "show full processlist" >> /tmp/morning_report.txt

