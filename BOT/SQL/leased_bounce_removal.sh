#!/bin/bash
dwhich=/usr/bin/which
dmysql=`$dwhich mysql`
decho=`$dwhich echo`
dcut=`$dwhich cut`
dlet=`$dwhich let`
dtest=`$dwhich test`
this_ip=`ifconfig -a | grep -o "ddr:67.217.39.[^ ]*" | grep -o "67.217.39.[^ ]*"`
echo "this_ip="$this_ip

this_ip=67.217.39.116

delog=/tmp/00leased_bounce_removal.txt
touch $delog
# this will grab all the campaigns that ended yesterday.
if prelim_data=`$dmysql -e "select  settings.ListServer as ListServer, campaigns.ListID as TableID, campaigns.AccountID as AccountID  from emarketing.campaigns as campaigns inner join emarketing.settings settings on campaigns.AccountID = settings.AccountID inner join emarketing.lists as lists on lists.TableID = campaigns.ListID where date_format(campaigns.endtime, '%Y-%m-%d')  = date_format(date_sub(current_date(), interval 1 day), '%Y-%m-%d') and settings.ListServer = \"$this_ip\" and lists.private = 0 " -u admin --password=spiedlen -h app`
then
        if test "$prelim_data" = ""
        then
                $decho "prelim_data variable was empty. Nothing to be done. " >> $delog
                exit
        fi

	counter=4
	temp=`$decho $prelim_data | $dcut -d' ' -f$counter`
	until test "$temp" = ""
	do
		ListServer=`$decho $prelim_data | $dcut -d' ' -f$counter`
		let "counter = counter + 1"
#		$decho "ListServer = $ListServer" >> $delog
		TableID=`$decho $prelim_data | $dcut -d' ' -f$counter`
		let "counter = counter + 1"
#		$decho "TableID = $TableID" >> $delog
		AccountID=`$decho $prelim_data | $dcut -d' ' -f$counter`
		let "counter = counter + 1"
#		$decho "AccountID = $AccountID" >> $delog
		fqtname=d$AccountID.$TableID
#		$decho "fqtname = $fqtname" >> $delog

#This is REAL slow. Need to speed it up. We will select to outfile and then read data infile.
#If I wanted, maybe I could tun this whole thing from the app server instead of on each list server.
#select * INTO OUTFILE '/tmp/tim_list_maryland_optins.txt' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' FROM datastore.tblmaster WHERE  ip != "" and source != "" and dtTimeStamp != "" AND region IN('md') ;
#		if bounce_data=`$dmysql -e " select email, Status, email_hash from $fqtname where Status in(85, 86)" -u admin --password=spiedlen -h $ListServer`
		if bounce_data=`$dmysql -e " select email, Status, email_hash into outfile \"/tmp/bounces.$ddate\" FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n' from $fqtname where Status in(85, 86)" -u admin --password=spiedlen -h $ListServer`
		then

			$dscp  /tmp/bounces.$ddate $app:/tmp/$ddate

			
			if test "$bounce_data" = ""
			then
				$decho "no bounces in this table" >> $delog
			else
				bounce_counter=4
				bounce_temp=`$decho $bounce_data | $dcut -d' ' -f$bounce_counter`
				
				until test "$bounce_temp" = ""
				do
					bounce_email=`$decho $bounce_data | $dcut -d' ' -f$bounce_counter`
					let "bounce_counter = bounce_counter + 1"
#					$decho "bounce_email = $bounce_email" >> $delog
					bounce_status=`$decho $bounce_data | $dcut -d' ' -f$bounce_counter`
					let "bounce_counter = bounce_counter + 1"
#					$decho "bounce_status = $bounce_status" >> $delog
					bounce_email_hash=`$decho $bounce_data | $dcut -d' ' -f$bounce_counter`
					let "bounce_counter = bounce_counter + 1"
#					$decho "bounce_email_hash = $bounce_email_hash" >> $delog
					if test "$bounce_email_hash" = ""
					then
						break
					else
#						if bounce_insert=`$dmysql -e "insert ignore into datastore.tblbounces (email, Status, email_hash) values (\"$bounce_email\",$bounce_status, $bounce_email_hash)" -u admin --password=spiedlen -h app`
#						then
							$decho "bounce insert succeeded" >> $delog
#						else
#							$decho "bounce insert failed" >> $delog
#						fi
					fi

				done
			fi
		else
			$decho "select email, Status, email_hash from $fqtname where Status in(85, 86) failed" >> $delog
		fi

	done
	
else
	$decho "initial select failed" >> $delog
fi



