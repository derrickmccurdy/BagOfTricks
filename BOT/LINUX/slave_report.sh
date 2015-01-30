#!/bin/bash
echo "

Number of records in datastore.tblmaster as of "`date`
echo "
Records:`mysq -e "select count(*) from datastore.tblmaster" -u admin --password=spiedlen -h 216.66.17.204`


" >> /tmp/record reporting.txt








echo "Number of records added in past 24 hours:`mysq -e \"select count(*) from datastore.tblmaster where dateadded > DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAYS) \" -u admin --password=spiedlen -h 216.66.17.204`

"
echo "


216.66.17.180" >> /tmp/SLAVE_RESULTS.txt 
mysql -e "$1" -u admin --password=spiedlen -h 216.66.17.180 >> /tmp/SLAVE_RESULTS.txt 2>&1

less /tmp/SLAVE_RESULTS.txt 


#BOUNCES



#SUPPRESSIONS



#TBLMASTER
