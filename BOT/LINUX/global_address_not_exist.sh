#!/bin/bash
load_address_not_exist () {
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
#/expedite/mylogin_uploaded/86_2010-08-24_lxls54.axcelinternet.com.csv
				echo "/expedite/mylogin_uploaded/86_$outfile_date_suffix$temp"
#truncate the temp table each time through the loop so we can accurately keep track of the dings
				if truncate_temp_table=`/usr/bin/mysql -e "truncate table datastore.global_address_not_exist_temp" -u admin --password=spiedlen `
				then
					echo "Successfully truncated table datastore.global_address_not_exist_temp"
				else
					echo "failed to truncate datastore.global_address_not_exist_temp"
				fi

# load the data from all the outfiles into datastore.global_
				if loadfile_execution=`/usr/bin/mysql -e "load data infile \"/expedite/mylogin_uploaded/86_$outfile_date_suffix$temp.csv\"  ignore into table datastore.global_address_not_exist_temp fields terminated by ',' optionally  enclosed by '\"' lines terminated by '\n' (@discard_id, email, email_hash, status, fqtname, dings)" -u admin --password=spiedlen `
				then
					echo "successfully loaded records from /expedite/mylogin_uploaded/86_$outfile_date_suffix$temp"
					if loadfile_execution2=`/usr/bin/mysql -e "insert into datastore.global_address_not_exist (email, email_hash, status, fqtname, dings ) select email, email_hash, status, fqtname, dings from datastore.global_address_not_exist_temp  on duplicate key update datastore.global_address_not_exist.dings = datastore.global_address_not_exist.dings + datastore.global_address_not_exist_temp.dings" -u admin --password=spiedlen `
					then
						echo "successfully loaded records from datastore.global_address_not_exist_temp into datastore.global_address_not_exist"
					else
						echo "failed to load records from datastore.global_address_not_exist_temp into datastore.global_address_not_exist"
					fi
				else
					echo "failed to load records from /expedite/mylogin_uploaded/86_$outfile_date_suffix$temp"
				fi

				let "counter = counter + 1"
				temp=`echo $prelim_data | /bin/cut -d' ' -f$counter`
			done
		fi
# add all the new records from datastore.global_address_not_exist to system.tblglobal_individual
		if datastore_fill_in=`/usr/bin/mysql -e "insert ignore into system.tblglobal_individual (email, email_hash, status, domain) select email, email_hash, 86, fqtname from datastore.global_address_not_exist " -u admin --password=spiedlen `
		then
			echo "successfully inserted into system.tblglobal_individual."
		else
			echo "failed to insert into system.tblglobal_individual."
		fi
	fi


}

load_address_not_exist
