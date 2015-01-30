#!/bin/bash
echo $1
#feed in table id
#get the list server IP, table name, and AccountID
#select * from emarketing.lists where  TableID = "t4476_48f64f901a2d3"
prelim_data=`/usr/bin/mysql -e "select l.AccountID as AccountID, s.ListServer as ListServer, l.TableID as TableID from emarketing.lists l inner join emarketing.settings s on l.AccountID = s.AccountID  where  l.ID = \"$1\"" -u admin --password=spiedlen -h app`

echo $prelim_data

#AccountID ListServer 4476 216.66.17.194
# get the variables assigned from the sql return

#AccountID=`echo $prelim_data | /bin/cut -d' ' -f4`
AccountID=`echo $prelim_data | /usr/bin/cut -d' ' -f4`
echo $AccountID
#ListServer=`echo $prelim_data | /bin/cut -d' ' -f5`
ListServer=`echo $prelim_data | /usr/bin/cut -d' ' -f5`
echo $ListServer
#TableID=`echo $prelim_data | /bin/cut -d' ' -f6`
TableID=`echo $prelim_data | /usr/bin/cut -d' ' -f6`
echo $TableID

#create the dedup table

#if create_dedup_table=`/usr/bin/mysql -e "CREATE TABLE d$AccountID.nodups ( email varchar(100) NOT NULL, firstname varchar(100) NOT NULL, lastname varchar(100) NOT NULL, phonenum varchar(100) NOT NULL, ConfirmedIP varchar(45) DEFAULT NULL, ConfirmedTS datetime DEFAULT NULL, Opener tinyint(1) unsigned DEFAULT NULL, OpenerIP varchar(45) DEFAULT NULL, OpenerTS datetime DEFAULT NULL, Clicker tinyint(1) unsigned DEFAULT NULL, ClickerIP varchar(45) DEFAULT NULL, ClickerTS datetime DEFAULT NULL, domain varchar(100) NOT NULL, Status tinyint(3) unsigned NOT NULL DEFAULT '0', Confirmed tinyint(1) unsigned DEFAULT NULL) " -u admin --password=spiedlen -h $ListServer`
if create_dedup_table=`/usr/bin/mysql -e "CREATE TABLE d$AccountID.nodups ( email varchar(100) NOT NULL,  ConfirmedIP varchar(45) DEFAULT NULL, ConfirmedTS datetime DEFAULT NULL, Opener tinyint(1) unsigned DEFAULT NULL, OpenerIP varchar(45) DEFAULT NULL, OpenerTS datetime DEFAULT NULL, Clicker tinyint(1) unsigned DEFAULT NULL, ClickerIP varchar(45) DEFAULT NULL, ClickerTS datetime DEFAULT NULL, domain varchar(100) NOT NULL, Status tinyint(3) unsigned NOT NULL DEFAULT '0', Confirmed tinyint(1) unsigned DEFAULT NULL) " -u admin --password=spiedlen -h $ListServer`
then
	echo "nodup table created successfully"
	#if select_out_data=`/usr/bin/mysql -e "insert into d$AccountID.nodups (email, domain, firstname, lastname, phonenum, Status, Confirmed, ConfirmedIP, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS) select email, domain, firstname, lastname, phonenum, max(Status), max(Confirmed), max(ConfirmedIP), max(Opener), max(OpenerIP), max(OpenerTS), max(Clicker), max(ClickerIP), max(ClickerTS) from d$AccountID.$TableID group by email"  -u admin --password=spiedlen -h $ListServer`
	if select_out_data=`/usr/bin/mysql -e "insert into d$AccountID.nodups (email, domain, Status, Confirmed, ConfirmedIP, Opener, OpenerIP, OpenerTS, Clicker, ClickerIP, ClickerTS) select email, domain,   max(Status), max(Confirmed), max(ConfirmedIP), max(Opener), max(OpenerIP), max(OpenerTS), max(Clicker), max(ClickerIP), max(ClickerTS) from d$AccountID.$TableID group by email"  -u admin --password=spiedlen -h $ListServer`
	then
		echo "selecting out non dup data successful"
		if rename_tables=`/usr/bin/mysql -e "rename tables d$AccountID.$TableID to d$AccountID.dups_$TableID, d$AccountID.nodups to d$AccountID.$TableID  " -u admin --password=spiedlen -h $ListServer`
		then
			echo "tables renamed successfully"
		else
			echo "problem renaming tables"
			#exit
		fi
	else
		echo "Problem selecting out non dup data "
		#exit
	fi

else
	echo "There was a problem creating the nodup table" 
	#exit
fi

#exit

