#!/bin/bash
dwhich=/usr/bin/which
dmysql=`$dwhich mysql`
decho=`$dwhich echo`
dcut=`$dwhich cut`
app=67.217.39.98
master=67.217.39.105
ddate=`$dwhich date`
this_date=`$ddate +"%Y-%m-%d"`
drsync=`$dwhich rsync`
dtouch=`$dwhich touch`
drm=`$dwhich rm`

delog=/tmp/00leased_bounce_removal.txt
$dtouch $delog
# this will grab all the campaigns that ended yesterday that were sent to leased lists.
#if prelim_data=`$dmysql -e "select  settings.ListServer as ListServer, campaigns.ListID as TableID, campaigns.AccountID as AccountID  from emarketing.campaigns as campaigns inner join emarketing.settings settings on campaigns.AccountID = settings.AccountID inner join emarketing.lists as lists on lists.TableID = campaigns.ListID where date_format(campaigns.endtime, '%Y-%m-%d')  = date_format(date_sub(current_date(), interval 1 day), '%Y-%m-%d') and lists.private = 0 " -u admin --password=spiedlen -h $app`
if prelim_data=`$dmysql -e "select  settings.ListServer as ListServer, campaigns.ListID as TableID, campaigns.AccountID as AccountID  from emarketing.campaigns as campaigns inner join emarketing.settings settings on campaigns.AccountID = settings.AccountID inner join emarketing.lists as lists on lists.TableID = campaigns.ListID where date_format(campaigns.endtime, '%Y-%m-%d')  > date_format(date_sub(current_date(), interval 7 day), '%Y-%m-%d') and lists.private = 0 " -u admin --password=spiedlen -h $app`
then
        if test "$prelim_data" = ""
        then
                $decho "prelim_data variable was empty. Nothing to be done. " >> $delog
                exit
        fi

#Loop through the results of the recent campaigns query
        counter=4
        temp=`$decho $prelim_data | $dcut -d' ' -f$counter`

        until test "$temp" = ""
        do
                ListServer=`$decho $prelim_data | $dcut -d' ' -f$counter`
                let "counter = counter + 1"
                $decho "ListServer = $ListServer" >> $delog
                TableID=`$decho $prelim_data | $dcut -d' ' -f$counter`
                let "counter = counter + 1"
                $decho "TableID = $TableID" >> $delog
                AccountID=`$decho $prelim_data | $dcut -d' ' -f$counter`
                let "counter = counter + 1"
                $decho "AccountID = $AccountID" >> $delog
                fqtname=d$AccountID.$TableID
                $decho "fqtname = $fqtname" >> $delog

#Select the data that we want to insert into the main database's copy of datastore.tblbounces to an outfile.
                if bounce_data=`$dmysql -e " select email, Status, email_hash, $AccountID INTO OUTFILE \"/tmp/bounces.$this_date.$AccountID.$TableID.txt\" FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n' FROM  $fqtname where Status in(85, 86)" -u admin --password=spiedlen -h $ListServer`
                then
			$decho "bounce records successfully sent to outfile from $fqtname " >> $delog
#Copy that outfile here to the main databases server from the remote list server
			if data_rsync=`$drsync -avz -e ssh $ListServer:/tmp/bounces.$this_date.$AccountID.$TableID.txt /tmp/bounces.$this_date.$AccountID.$TableID.txt`
			then
				$decho "bounce records successfully retreived from $ListServer " >> $delog
#Read the data in from that file and insert it into the master copy of datastore.tblbounces
				if bounce_insert_data=`$dmysql -e " load data local infile \"/tmp/bounces.$this_date.$AccountID.$TableID.txt\" ignore into table datastore.tblbounces FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY \"\n\" (email, Status, email_hash, CustID)" -u admin --password=spiedlen `
				then
					$decho "bounce records successfully inserted from $ListServer $fqtname" >> $delog
				else
					$decho "bounce record insertion FAILED from $ListServer $fqtname" >> $delog
				fi
			else
					$decho "bounce records retreival FAILED from $ListServer " >> $delog
			fi
		else
			$decho "bounce records send to outfile FAILED from $fqtname " >> $delog
		fi
        done
	$drm -f /tmp/bounces.*
else
        $decho "initial select failed" >> $delog
fi

