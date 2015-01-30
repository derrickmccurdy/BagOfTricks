#!/bin/bash
#http://student.northpark.edu/pemente/sed/sed1line.txt
sed --in-place 's/^/\\. /' /home01/derrick/master_sql_executable.sql




sed -r --in-place  -e ~derrick/BOT/LINUX/sed_script.txt ~derrick/Desktop/Professional/EXPEDITE/PersonQuery.html






#THIS WORKS!
sed -n -e '/<tr class=.*/ {
N
N
N
N
N
N
N
N
N
N
N
N
N
N
N
N
N
N
N
N
N
N
N
N
N
/\n.*/ p
}' /home/derrick/Desktop/Professional/EXPEDITE/PersonQuery.html2 | less




#no... THIS WOOOOORKS!
sed -n '
/.*mailto:.*/ {
H
n
H
n
H
n
x
s/.*linkPerson[^>]*>\([^<]*\)<.*mailto:\([^"]*\)".*\n[^<]*[^>]*>\([^<]*\)<.*\n.*<a[^>]*>\([^<]*\)<.*/\1\t\2\t\3\t\4/
p
}' /home/derrick/Desktop/Professional/EXPEDITE/PersonQuery.html2 | less


#this puts the firstname and lastname in the last column
sed -n '
/.*mailto:.*/ {
H
n
H
n
H
n
x
s/.*linkPerson[^>]*>\([^<]*\)<.*mailto:\([^"]*\)".*\n[^<]*[^>]*>\([^<]*\)<.*\n.*<a[^>]*>\([^<]*\)<.*/\2\t\3\t\4\t\1/
p
}' /home/derrick/Desktop/Professional/EXPEDITE/PersonQuery.html2 > /home/derrick/drive2/zoom/one.csv


#this finds the lastname, first name and separates them.
sed 's/^\(.*\)\t\([^,]*\), \(.*\)$/\1\t\2\t\3/' < /home/derrick/drive2/zoom/one.csv | less


