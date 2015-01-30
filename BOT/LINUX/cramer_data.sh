##!/bin/bash
#
##RARFILES=`ls -a *.rar | cut -d " "  -f8`
##for r in $RARFILES; do
##	echo "decompressing $r"
##	unrar x "$r" /home/derrick/Desktop/professional/EXPEDITE/LISTS/cramer_data/
##done
#
#
##FILES=`ls -a *.csv | cut -d " "  -f8`
#FILES=`ls -a *.txt | cut -d " "  -f8`
#for f in "$FILES"
#do 
#	LINES=`cat $f | wc -l`
#	echo "$f has $LINES"
#	let "LINES=LINES-1"
#	echo "newlines = $LINES"
#	#head -n 1 $f | less
#	tail -n $LINES $f >> XXX.csvx
#done










#!/bin/bash

#RARFILES=`ls -a *.rar | cut -d " "  -f8`
ZIPFILES=`ls -a *.zip | cut -d " "  -f8`
for r in $ZIPFILES; do
       echo "decompressing $r"
       unzip -o "$r" -d /home/derrick.my-login.net/httpdocs/LISTS/kombol/2008/
       #echo "$r"
done


##FILES=`ls -a *.csv | cut -d " "  -f8`
#FILES=`ls -a *.txt | cut -d " "  -f8`
#for f in "$FILES"
#do
#        LINES=`cat $f | wc -l`
#        echo "$f has $LINES"
#        let "LINES=LINES-1"
#        echo "newlines = $LINES"
#        #head -n 1 $f | less
#        tail -n $LINES $f >> XXX.csvx
#done

find /home/derrick.my-login.net/httpdocs/LISTS/kombol/2008/ -name "*" -print > ~derrick/kombol2008.txt


echo "load data local  infile  '/home01/derrick/kombol2008.txt' into table masterimportarchive FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n' (AccountID, filename) SET keywords = \"not processed\" ;"




