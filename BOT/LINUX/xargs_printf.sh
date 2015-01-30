

#This command finds all the temp tables .MYD files that have not been accessed for more than 30 days. The resulting output is piped to grep which returns the full path and file name minus the .MYD extension. That output is sent to echo via xargs where .* is appended to it which in turn is sent to the file /tmp/rfiles_tmp.txt. The printf command then reads each line and expands the .*. That is then send to du via xargs to find out how much disk space is being used by those files.
find /var/lib/mysql/ -name "r[0-9]*_*.MYD"  -atime +35 -print | grep -o -E "\/[^\.]*" | xargs -I{} echo {}.* > /tmp/rfiles_tmp.txt ; printf "'%s'\n" $(< /tmp/rfiles_tmp.txt) | xargs du -h -c





cp -r --parents /home/derrick/BOT/LINUX/* /tmp/dtest/

#this command copies the files to /var/lib/mysql/drfiles/ and maintains directory structure. It also changes the atime of the files so it will only work once.
mkdir /var/lib/mysql/drfiles ; find /var/lib/mysql/ -name "r[0-9]*_*.MYD"  -atime +35 -print | grep -o -E "\/[^\.]*" | xargs -I{} echo {}.* > /tmp/rfiles_tmp.txt ; printf "'%s'\n" $(< /tmp/rfiles_tmp.txt) | xargs cp --parents -t /var/lib/mysql/drfiles/ 


#so we need to do this...
mkdir /var/lib/mysql/drfiles ; find /var/lib/mysql/ -name "r[0-9]*_*.MYD"  -mtime +35 -print | grep -o -E "\/[^\.]*" | xargs -I{} echo {}.* > /tmp/rfiles_tmp.txt ; printf "'%s'\n" $(< /tmp/rfiles_tmp.txt) | xargs cp -p --parents -t /var/lib/mysql/drfiles/ ; printf "'%s'\n" $(< /tmp/rfiles_tmp.txt) | xargs rm -f  



mkdir /var/lib/mysql/drfiles ; find /var/lib/mysql/ -name "r[0-9]*_*.MYD"  -mtime +35 -print | grep -o -E "\/[^\.]*" | xargs -I{} echo {}.* > /tmp/rfiles_tmp.txt ; printf "'%s'\n" $(< /tmp/rfiles_tmp.txt) | xargs rm -f   

