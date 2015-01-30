#!/bin/bash
dwhich=/usr/bin/which
ddate=`$dwhich date`
today=`$ddate +"%F"`
dscp=`$dwhich scp`
drsync=`$dwhich rsync`
dmysql=`$dwhich mysql`
dtouch=`$dwhich touch`

#$dtouch /tmp/unclosed_leads.$today

#$dmysql -e "select Email, CONV(SUBSTR(MD5(LOWER(\`Email\`)),19,32),16,10), Firstname, LastName, Employer into outfile \"/tmp/unclosed_leads.$today\" FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n' from leads.contact_forms where OrigAccountId = 2 and date_format(DateTime, '%Y-%m-%d') < date_sub(current_date(), interval \"56\" day) and date_format(DateTime, '%Y-%m-%d') > date_sub(current_date(), interval \"62\" day) and status <> \"Closed\"" -u admin --password=spiedlen -h 67.217.39.98 

#$dmysql -e "select Email, CONV(SUBSTR(MD5(LOWER(\`Email\`)),19,32),16,10), Firstname, LastName, Employer into outfile \"/tmp/other_unclosed_leads.$today\" FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n' from leads.contact_forms where OrigAccountId <> 2 and date_format(DateTime, '%Y-%m-%d') < date_sub(current_date(), interval \"56\" day) and date_format(DateTime, '%Y-%m-%d') > date_sub(current_date(), interval \"62\" day) and status <> \"Closed\"" -u admin --password=spiedlen -h 67.217.39.98 

#$drsync -avz -e ssh 67.217.39.98:/tmp/unclosed_leads.$today /tmp/unclosed_leads.$today
#$drsync -avz -e ssh  /tmp/unclosed_leads.$today 67.217.39.119:/tmp/unclosed_leads.$today

#$drsync -avz -e ssh 67.217.39.98:/tmp/unclosed_leads.$today /tmp/other_unclosed_leads.$today
#$drsync -avz -e ssh  /tmp/unclosed_leads.$today 67.217.39.119:/tmp/other_unclosed_leads.$today

#$dmysql -e "load data local infile \"/tmp/unclosed_leads.$today\" ignore into table t2_unclosedleads FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n'  (email, email_hash, firstname, lastname, employer)"  -u admin --password=spiedlen -h 67.217.39.119 -D d2 

#$dmysql -e "load data local infile \"/tmp/other_unclosed_leads.$today\" ignore into table t2_other_unclosed_leads FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n'  (email, email_hash, firstname, lastname, employer)"  -u admin --password=spiedlen -h 67.217.39.119 -D d2 


#$dmysql -e "update emarketing.lists set ListName = \"$today unclosed leads\" where TableID = \"t2_jerry_unclosed_leads\"" -u admin --password=spiedlen -h 67.217.39.98 
#$dmysql -e "update emarketing.lists set ListName = \"$today other unclosed leads\" where TableID = \"t2_other_unclosed_leads\"" -u admin --password=spiedlen -h 67.217.39.98 






#unclosed leads
$dmysql -e "insert into d2.t2_unclosedleads (email, email_hash, firstname, lastname, employer) select Email, CONV(SUBSTR(MD5(LOWER(\`Email\`)),19,32),16,10), Firstname, LastName, Employer from leads.contact_forms where OrigAccountId = 2 and date_format(DateTime, '%Y-%m-%d') < date_sub(current_date(), interval \"56\" day) and date_format(DateTime, '%Y-%m-%d') > date_sub(current_date(), interval \"62\" day) and status <> \"Closed\""  -u admin --password=spiedlen -h 184.82.128.98 -D d2

#other unclosed leads
$dmysql -e "insert into d2.t2_other_unclosed_leads (email, email_hash, firstname, lastname, employer) select Email, CONV(SUBSTR(MD5(LOWER(\`Email\`)),19,32),16,10), Firstname, LastName, Employer from leads.contact_forms where OrigAccountId <> 2 and date_format(DateTime, '%Y-%m-%d') < date_sub(current_date(), interval \"56\" day) and date_format(DateTime, '%Y-%m-%d') > date_sub(current_date(), interval \"62\" day) and status <> \"Closed\""  -u admin --password=spiedlen -h 184.82.128.98 -D d2


$dmysql -e "update emarketing.lists set ListName = \"$today unclosed leads\" where TableID = \"t2_jerry_unclosed_leads\"" -u admin --password=spiedlen -h 184.82.128.98 
$dmysql -e "update emarketing.lists set ListName = \"$today other unclosed leads\" where TableID = \"t2_other_unclosed_leads\"" -u admin --password=spiedlen -h 184.82.128.98 

