#!/bin/bash
# first draft, pre-test, 3 Feb 2024
# 
# created by Sander van Vugt, mail@sandervanvugt.nl
# please send suggestions for improvement to the above email address

clear
ls /root &>/dev/null || (echo run this script with root privileges && exit 2)

SCORE=0

#### TASK 1
echo -e "\033[1mchecking task 1 results\033[0m"
if [ -f /root/archive.tgz ] &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t file /root/archive.tgz was found"
	SCORE=$(( SCORE + 10 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t I can't find the file /root/archive.tgz. Did you use \033[1mtar -cvf\033[0m to create it?" 
fi

if tar -tvf /root/archive.tgz | grep 'etc/hosts' &>/dev/null
then
	echo -e "\033[31m[FAIL]\033[0m\t\t You have created a tarball, but it doesn't contain relative filenames"
elif tar -tvf /root/archive.tgz | grep 'hosts' &>/dev/null
then	
	echo -e "\033[32m[OK]\033[0m\t\t The random file check on the tarball was succesful"
	SCORE=$(( SCORE + 30 ))
fi
echo -e "\n"

### task2
echo -e "\033[1mevaluating task 2\033[0m"

if [ -f /var/tmp/users ] &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t The file /var/tmp/users was found"
	SCORE=$(( SCORE + 10 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t File /var/tmp/users was not found. Did you create it in the wrong place?"
fi

if [[ $(head -n 1 /var/tmp/users) == adm ]] &>/dev/null
then
	echo -e "\033[32[OK]\033[0m\t\t The file /var/tmp/users has the expected username on the first line"
	SCORE=$(( SCORE + 30 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t The first line of the file /var/tmp/users didn't contain the expected username. Are you sure you have used \033[1msort\033[0m to sort the output?"
fi
echo -e "\n"

###task 3
echo -e "\033[1mevaluating task 3\033[0m"
if id bob &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t User bob exists"
	SCORE=$(( SCORE + 10 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t User bob was not found. Did you forget to use \033[1museradd\033[0m to create the user?"
fi

if [ ! -d /root/userfiles ] &>/dev/null
then
	echo -e "\033[31m[FAIL]\033[0m\t\t Directory /root/userfiles not found"
else
	SCORE=$(( SCORE + 10 ))
fi

if ls -a /root/userfiles/ | grep bash &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t Random file check on user bob files passed"
	SCORE=$(( SCORE + 30 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t Random file check failed. Did you use \033[1mfind -user bob -exec cp -a {} /root/userfiles/ \;\033[0m to copy files owned by user bob?"
fi

### FINAL GRADING
echo -e "\n"
echo -e "\033[1myour total score is $SCORE out of a total of 130\033[0m"

if [[ $SCORE -ge $(( 130 / 10 * 7 )) ]]
then
	echo -e "\033[32mCONGRATULATIONS!!\033[0m\t\t You passed this entry test!"
else
	echo -e "\033[31m[FAIL]\033[0m\t\t You did NOT pass this entry test. Carefully study topics in the first 6 lessons in https://learning.oreilly.com/videos/-/9780137931521/"
fi
