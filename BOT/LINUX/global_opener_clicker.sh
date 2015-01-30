#!/bin/bash
load_openers_clickers () {
#initialize the outfile suffix variable
	outfile_date_suffix=`/bin/date +%Y-%m-%d_`
#get the appropriate aliases of the list servers from the app machine
	if prelim_data=`/usr/bin/mysql -e "select host_name from system.ls_aliases where alias like \"ls%\"" -u admin --password=spiedlen `
	then
		if test "$prelim_data" = ""
		then
			echo "prelim_data variable was empty. Nothing to be done. "
			exit
		else
			counter=2
			temp=`echo $prelim_data | /bin/cut -d' ' -f$counter`
#loop through them all
			until test "$temp" = ""
			do
				echo $temp
				echo "/expedite/mylogin_uploaded/$outfile_date_suffix$temp"
# load the data from all the outfiles into datastore.global_opener_clicker
				if loadfile_execution=`/usr/bin/mysql -e "load data infile \"/expedite/mylogin_uploaded/$outfile_date_suffix$temp.csv\"  replace into table datastore.global_opener_clicker fields terminated by ',' optionally  enclosed by '\"' lines terminated by '\n' (@discard_id, email ,email_hash ,domain ,Confirmed ,ConfirmedIP ,ConfirmedTS ,Opener ,OpenerIP ,OpenerTS ,Clicker ,ClickerIP ,ClickerTS)" -u admin --password=spiedlen `
				then
					echo "successfully loaded records from /expedite/mylogin_uploaded/$outfile_date_suffix$temp"
				else
					echo "failed to load records from /expedite/mylogin_uploaded/$outfile_date_suffix$temp"
				fi
				let "counter = counter + 1"
				temp=`echo $prelim_data | /bin/cut -d' ' -f$counter`
			done
		fi
# pull in the other data from datastore.tblmaster into global_opener_clicker
		if datastore_fill_in=`/usr/bin/mysql -e "update datastore.global_opener_clicker as oc inner join datastore.tblmaster as master on oc.email_hash = master.email_hash set oc.firstname = master.firstname ,oc.middlename = master.middlename ,oc.lastname = master.lastname ,oc.address = master.address ,oc.address2 = master.address2, oc.city = master.city ,oc.county = master.county ,oc.region = master.region ,oc.zipcode = master.zipcode, oc.gender = master.gender ,oc.companyname = master.companyname ,oc.jobtitle = master.jobtitle, oc.industry = master.industry ,oc.phonearea = master.phonearea, oc.phonenum = master.phonenum ,oc.keywords = master.keywords , oc.born = master.born , oc.source = master.source , oc.dtTimeStamp = master.dtTimeStamp , oc.dateadded = master.dtTimeStamp ,oc.ip = master.ip , oc.country_short = master.country_short" -u admin --password=spiedlen `
		then
			echo "successfully filled in the data from datastore.tblmaster"
		else
			echo "failed to fill in the data from datastore.tblmaster"
		fi
	fi


}

load_openers_clickers

#BOT/LINUX/global_opener_clicker.sh: line 4: =/bin/date: No such file or directory
#BOT/LINUX/global_opener_clicker.sh: line 8: test: too many arguments
#BOT/LINUX/global_opener_clicker.sh: line 14: /bin/cut: No such file or directory
