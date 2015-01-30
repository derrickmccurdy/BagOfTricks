#!/bin/bash

#need to empty out the old temp files.
HOLDER=/home/derrick/drive2/zoom/one.csv
RESULT=/home/derrick/drive2/zoom/result.csv
echo "" > $HOLDER
echo "Email,jobtitle,companyname,lastname,firstname" > $RESULT

#we will put all of the saved .html files into a specified location.
#then we will "find" each of those html files and feed them into the sed loop.
#find /home/derrick/drive2/zoom/ -name "*.html" -

#HTMLFILES=`find /home/derrick/drive2/zoom/*.html`
#10001  10007  10012  10017  10022  10026  10038
#10002  10009  10013  10018  10023  10028  10128
#10003  10010  10014  10019  10024  10029  
#10004  10011  10016  10021  10025  10036
HTMLFILES=`find /home/derrick/drive2/zoom/$1/ -name "*.html"`
for r in $HTMLFILES; do
       echo "$r"
	#this pulls out the email, jobtitle, companyname, and lastname COMMA firstname and puts the firstname and lastname in the last column
	sed -n -e '
	/.*mailto:.*/ {
	H
	n
	H
	n
	H
	n
	x
	s/.*linkPerson[^>]*>\([^<]*\)<.*mailto:\([^"]*\)".*\n[^<]*[^>]*>\([^<]*\)<.*\n.*<a[^>]*>\([^<]*\)<.*/\2\t\3\t\4\t\1/
	s/^\(.*\)\t\([^,]*\), \(.*\)$/\1\t\2\t\3/
	s/\&nbsp;//g
	s/\t/","/g
	s/^\(.*\)$/"\1"/
	p
	}' < $r >> $RESULT

	#perhaps this can go inside of the command above
	#this finds the lastname COMMA firstname and separates them.
	#sed -n -e 's/^\(.*\)\t\([^,]*\), \(.*\)$/\1\t\2\t\3/ p' < $HOLDER >> $RESULT

done
find /home/derrick/drive2/zoom/ -name "*.html" -exec rm -f '{}' \;
echo $RESULT
