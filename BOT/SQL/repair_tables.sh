#this will tell you roughly how many tables are crashed
sudo myisamchk -F /var/lib/mysql/d[0-9]*/*.MYI >> /tmp/dbcheck 2>&1 ; sudo grep -o "\-\-\-\-\-" /tmp/dbcheck | wc -l
#This will repair the tables
sudo myisamchk -r --key_buffer_size=64M --sort_buffer_size=64M --read_buffer_size=1M --write_buffer_size=1M  /var/lib/mysql/d[0-9]*/*.MYI >> /tmp/dbrepair 2>&1
#on another terminal, you can watch the tables as they are repaired.
sudo tail -f /tmp/dbrepair




#if you ever get a 130 error "wrong file format" use this command:
repair table table_name use_frm ;
