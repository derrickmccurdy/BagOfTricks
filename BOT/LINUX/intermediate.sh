#!/bin/bash
sudo rsync -avz -e ssh /tmp/sql_command_file* 209.8.109.203:/tmp/
sudo rsync -avz -e ssh /tmp/newfile* 209.8.109.203:/tmp/
#sudo find  /home/derrick.my-login.net/httpdocs/LISTS/kombol/2007 -print > /home/derrick.my-login.net/httpdocs/kombol2007.txt
sudo find  /tmp/sql_command_file* -print > /home01/derrick/master_sql_executable.sql
sed --in-place 's/^/\\. /' /home01/derrick/master_sql_executable.sql
sudo rm /tmp/sql_command_file*
sudo rm /tmp/newfile*
