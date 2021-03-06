#!/bin/bash

RESULT=/home/derrick/drive2/zoom/result.csv
#RESULT=/home/derrick/drive2/zoom/
echo "Email,jobtitle,companyname,lastname,firstname,region,country_short" > $RESULT

#we will put all of the saved .html files into a specified location.
#then we will "find" each of those html files and feed them into the sed loop.
#find /home/derrick/drive2/zoom/melissa/Electrical_Contracting_SbS/ -name "*.html" -

#HTMLFILES=`find /home/derrick/drive2/zoom/kramer/*.html`
STATE_FOLDERS="AK AR CA CT DE GA IA IL KS LA ME MN MS NC NE NJ NV OH OR RI SD TX VA WA WV AL AZ CO DC FL HI ID IN KY MA MD MI MO MT ND NH NM NY OK PA SC TN UT VT WI WY"
for g in $STATE_FOLDERS; do
#	echo $g
	HTMLFILES=`find /home/derrick/drive2/zoom/$1/$g/*.html`
	for r in $HTMLFILES; do
#		echo $HTMLFILES
#	       echo "$r"
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
s/^\(.*\)$/"\1","'$g'","US"/
p
}' < $r >> $RESULT

	done
done

find /home/derrick/drive2/zoom/ -name "*.html" -exec rm -f '{}' \;
echo $RESULT

#s/^\(.*\)$/"\1"/
