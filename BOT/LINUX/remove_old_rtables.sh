#!/bin/bash
#select concat(s.ListServer,":/var/lib/mysql/d",c.AccountID,"/",c.tmpTableID,".*") from emarketing.campaigns as c inner join emarketing.settings as s on c.AccountID = s.AccountID where date_format(c.schedule, '%Y-%m-%d') < date_format(date_sub(now(), interval 35 day), '%Y-%m-%d') and date_format(c.schedule, '%Y-%m-%d') > date_format(date_sub(now(), interval 70 day), '%Y-%m-%d') and tmpTableID <> "" limit 10 ;
/bin/echo "" >>  /tmp/rlog_file
remove_old_rtables () {

/usr/bin/find /var/lib/mysql/ -name "r[0-9]*_*.MYD"  -mtime +35 -print | /bin/grep -o -E "\/[^\.]*" | /usr/bin/xargs -I{} /bin/echo {}.* > /tmp/rfiles_tmp.txt ; /usr/bin/printf "'%s'\n" $(< /tmp/rfiles_tmp.txt) | /usr/bin/xargs /bin/rm -f
/bin/echo $HOSTNAME
/usr/bin/printf "'%s'\n" $(< /tmp/rfiles_tmp.txt) | /usr/bin/xargs /bin/echo 

}

remove_old_rtables >> /tmp/rlog_file 2>&1
