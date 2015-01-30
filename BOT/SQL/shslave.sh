#!/bin/bash
echo "


lsim0 " > /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h lsim0 >> /tmp/SLAVE_RESULTS.txt 
echo "


lsim1 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h lsim1 >> /tmp/SLAVE_RESULTS.txt 
echo "


lsim2 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h lsim2 >> /tmp/SLAVE_RESULTS.txt 
echo "


lsim3 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h lsim3 >> /tmp/SLAVE_RESULTS.txt 
echo "


ls00 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h ls00 >> /tmp/SLAVE_RESULTS.txt 2>&1
echo "


ls01 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h ls01 >> /tmp/SLAVE_RESULTS.txt 2>&1
echo "


ls02 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h ls02 >> /tmp/SLAVE_RESULTS.txt 2>&1
echo "


ls03 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h ls03 >> /tmp/SLAVE_RESULTS.txt 2>&1
echo "


ls10 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h ls10 >> /tmp/SLAVE_RESULTS.txt 2>&1
echo "


ls11 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h ls11 >> /tmp/SLAVE_RESULTS.txt 2>&1
echo "


ls12 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h ls12 >> /tmp/SLAVE_RESULTS.txt 2>&1
echo "


ls13 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h ls13 >> /tmp/SLAVE_RESULTS.txt 2>&1
echo "


ls20 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h ls20 >> /tmp/SLAVE_RESULTS.txt 2>&1
echo "


ls21 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h ls21 >> /tmp/SLAVE_RESULTS.txt 2>&1
echo "


ls22 " >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h ls22 >> /tmp/SLAVE_RESULTS.txt 2>&1
echo "


ls23" >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h ls23 >> /tmp/SLAVE_RESULTS.txt 2>&1

less /tmp/SLAVE_RESULTS.txt 
