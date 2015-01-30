#!/bin/bash
# This script is run from a cron once per day on the "nis server".
# It grabs campaign records where the campaign endtime is more than 72 hours in the past. List must be "inhouse" cannot be "protected" 


/bin/echo `/bin/date` >> /tmp/00InhouseCampaignListCleanuplog.txt

if prelim_data=`/usr/bin/mysql -e "SELECT c.AccountID as AccountID, s.ListServer AS ListServer, l.TableID AS TableID, l.ID as ListID FROM emarketing.campaigns c INNER JOIN  emarketing.lists l ON c.ListID = l.TableID INNER JOIN emarketing.settings s ON l.AccountID = s.AccountID INNER JOIN system.accounts a ON s.AccountID = a.AccountID WHERE c.endtime < DATE_SUB(NOW(), INTERVAL 3 DAY) AND c.endtime > DATE_SUB(NOW(), INTERVAL 7 DAY) AND a.EmailMarketingInhouseEnabled = 1 AND l.list_code != 0 AND l.protected = 0 AND c.statusInt = \"2\" " -u admin --password=spiedlen -h 67.217.39.98` 
then
        if /usr/bin/test "$prelim_data" = ""
        then
                /bin/echo "prelim_data variable was empty. Nothing to be done. " >> /tmp/00InhouseCampaignListCleanuplog.txt
                exit
        fi
	
	counter=5
	temp=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	until /usr/bin/test "$temp" = ""
	do
		#/bin/echo "prelim_data = $prelim_data " >> /tmp/00InhouseCampaignListCleanuplog.txt
		AccountID=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		let "counter = counter + 1"
		/bin/echo "AccountID = $AccountID" >> /tmp/00InhouseCampaignListCleanuplog.txt
		ListServer=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		let "counter = counter + 1"
		/bin/echo "ListServer = $ListServer" >> /tmp/00InhouseCampaignListCleanuplog.txt
		TableID=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		let "counter = counter + 1"
		/bin/echo "TableID = $TableID" >> /tmp/00InhouseCampaignListCleanuplog.txt
		ListID=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
		let "counter = counter + 1"
		/bin/echo "ListID = $ListID" >> /tmp/00InhouseCampaignListCleanuplog.txt



		#check that there are no future campaigns using this list
		check_data=`/usr/bin/mysql -e "select count(*) as future from emarketing.campaigns where listid = \"$TableID\" and accountid = $AccountID and statusint not in('900','2') and schedule > date_format(now(), \"%Y-%m-%d %H:%i:%s\")" -u admin --password=spiedlen -h 67.217.39.98`
		checked_data=`/bin/echo $check_data | /bin/cut -d' ' -f2`
		if [ "$checked_data" -eq 0 ] 
		then
			#/bin/echo "Future campaigns"
			#uncomment the following lines to test without performing operations on the database
			/bin/echo "/usr/bin/mysql -e \"DROP TABLE d$AccountID.$TableID\" -u admin --password=spiedlen -h $ListServer" >> /tmp/00InhouseCampaignListCleanuplog.txt
			if drop_command=`/usr/bin/mysql -e "DROP TABLE d$AccountID.$TableID" -u admin --password=spiedlen -h $ListServer`
			then
				/bin/echo "table d$AccountID.$TableID dropped successfully from $ListServer" >> /tmp/00InhouseCampaignListCleanuplog.txt
				if delete_list_entry_command=`/usr/bin/mysql -e "DELETE FROM emarketing.lists WHERE ID = $ListID LIMIT 1" -u admin --password=spiedlen -h 67.217.39.98`
				then
					/bin/echo "emarketing.lists entry deleted successfully." >> /tmp/00InhouseCampaignListCleanuplog.txt
				else
					/bin/echo "EMARKETING.LISTS DELETE FOR LISTID $ListID FAILED." >> /tmp/00InhouseCampaignListCleanuplog.txt
				fi
			else
				/bin/echo "DROP TABLE d$AccountID.$TableID FAILED" >> /tmp/00InhouseCampaignListCleanuplog.txt
			fi
		#else
		#	/bin/echo "No future campaigns"
		fi

		#set the temp variable to the contents of the next field
		temp=`/bin/echo $prelim_data | /bin/cut -d' ' -f$counter`
	done
	exit


else
        /bin/echo "PRELIM_DATA VARIABLE WAS EMPTY" >> /tmp/00InhouseCampaignListCleanuplog.txt
        exit
fi

