#!/bin/bash

echo "


lsim0 " > /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick lsim0  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


lsim1 " >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick lsim1  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


lsim2 " >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick lsim2  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


lsim3 " >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick lsim3  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


ls00 " >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick ls00  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
#echo "


#ls01 " >> /tmp/SLAVE_SHELL_RESULTS.txt 
#ssh -l derrick ls01  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


ls02 " >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick ls02  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


ls03 " >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick ls03  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


ls10 " >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick ls10  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


ls11 " >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick ls11  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


ls12 " >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick ls12  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


ls13 " >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick ls13  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


ls20" >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick ls20  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


ls21" >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick ls21  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


ls22" >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick ls22  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


ls23 " >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick ls23  "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 
echo "


ls30" >> /tmp/SLAVE_SHELL_RESULTS.txt 
ssh -l derrick ls30 "$1" >> /tmp/SLAVE_SHELL_RESULTS.txt 2>&1 

less /tmp/SLAVE_SHELL_RESULTS.txt 
