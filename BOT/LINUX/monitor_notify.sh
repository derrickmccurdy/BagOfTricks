app
master
lsim0
lsim1
lsim2
ls00
ls01
ls02
ls03
ls10
ls11
ls12
ls13
ls20
ls21
ls22
ls23

special = ls13, ls12, ls01

#monitor disk space on all these servers.
#	need immediate notification if list server disk space drops below 20 G
ssh -l derrick lsim0 df --si /var/lib/mysql | sed -n -e  's/ \+/ /g ' -e '/^ .*/ p' | cut -d' ' -f4 | sed -e 's/G//g'
	# test if result is numeric
	# test if result is greater than 20


#too many connections to db server
#	List server will probably need to be restarted. Cause of too many connections will need to be rectified.
ERROR 1040 (00000): Too many connections

#campaign_prep
#	need notification immediately if status_int is anything other than 1000, 1100, or 1200
mysql -u admin --password=spiedlen -h ls01 -e "select * from emarketing.status where status_int not in(1000,1200, 1100)" ;
#crashed tables
#	need notification immediately if a table crashes
			#this will tell you roughly how many tables are crashed
			sudo myisamchk -F /var/lib/mysql/d[0-9]*/*.MYI >> /tmp/dbcheck 2>&1 ; sudo grep -o "\-\-\-\-\-" /tmp/dbcheck | wc -l
			#This will repair the tables
			sudo myisamchk -r --key_buffer_size=64M --sort_buffer_size=64M --read_buffer_size=1M --write_buffer_size=1M  /var/lib/mysql/d[0-9]*/*.MYI >> /tmp/dbrepair 2>&1
			#on another terminal, you can watch the tables as they are repaired.
			sudo tail -f /tmp/dbrepair
			#if you ever get a 130 error "wrong file format" use this command:
			repair table table_name use_frm ;

#replication errors
#	need email notification if replication falls behind more that X number of seconds
	mysql -u admin --password=spiedlen -h lsim0 -e "show slave status" | sed -n -e '/settings/ p' -e 's/|/	/' -e 's/	\+/	/g' | cut -f33
	# test if that number is less than X or not


#event and sproc errors
#	need to get errors from sprocs and events, some immediate and some via email.

#client list upload errors in simplicity
#	need email notification if inserts fail. Cause will have to be rectified. Column name prohibition needs to be tightened up and meaningful errors reported to user.
#table does not exist
#	need to know why a table does not exist immediately. tables missing in mysql but mentioned in emarketing.lists need to be removed from emarketing.lists and the cause corrected.
