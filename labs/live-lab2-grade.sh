#!/bin/bash
# first draft, pre-test, 6 Feb 2024
# 
# created by Sander van Vugt, mail@sandervanvugt.nl
# please send suggestions for improvement to the above email address

# checking this script runs as root
clear
ls /root &>/dev/null || (echo run this script with root privileges && exit 2)

###check password validity set to 90 days
if grep 'PASS_MAX_DAYS.*90' /etc/login.defs &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t password validity set correctly"
else
	echo -e "\033[31m[FAIL]\033[0m\t\\t password validity is not set correctly" 
fi

###check empty file newfile is created in new user home directories
if [ -f /etc/skel/newfile ] &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t file \033[1mnewfile\033[0m will be created in new user home directories"
else
	echo -e "\033[31m[FAIL]\033[0m\t\\t file \033[1mnewfile\033[0m will not be created in new user home directories" 
fi

###check for users anna, anouk, linda and lisa
for i in anna anouk linda lisa
do
	if id $i &>/dev/null
	then 
		echo -e "\033[32m[OK]\033[0m\t\t user $i was found"
	else
		echo -e "\033[31m[FAIL]\033[0m\t\\t user $i was not found"
	fi
done

echo -e "\033[33m[WARNING]\033[0m\t I'm not smart enough to test the user password is set correctly"

###check groups profs and students

if grep 'profs' /etc/group && grep 'students' /etc/group &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t groups profs and students were found"
else
	echo -e "\033[31m[FAIL]\033[0m\t\\t groups profs and students were not found" 
fi
###check anna anouk profs membership and linda lisa students
if grep profs /etc/group | grep anna | grep anouk &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t group profs has users anna and anouk as members"
else
	echo -e "\033[31m[FAIL]\033[0m\t\\t group profs doesn't have users anna and anouk as members" 
fi

if grep students /etc/group | grep linda | grep lisa &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t group students has users linda and lisa as members"
else
	echo -e "\033[31m[FAIL]\033[0m\t\\t group studens doesn't have users linda and lisa as members" 
fi
