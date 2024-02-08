#!/bin/bash
# 
# created by Sander van Vugt, mail@sandervanvugt.nl
# please send suggestions for improvement to the above email address

clear
ls /root &>/dev/null || (echo run this script with root privileges && exit 2)

SCORE=0
TOTAL=0

#### TASK 1
echo -e "\033[1mchecking task 1 results\033[0m"
if true
then
	echo -e "\033[32m[OK]\033[0m\t\t "
	SCORE=$(( SCORE + 10 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t "
fi
TOTAL=$(( TOTAL + 10 ))

#### print PASS/FAIL
echo -e "\n"
echo your score is $SCORE out of a total of $TOTAL

if [[ $SCORE -ge $(( TOTAL / 10 * 7 )) ]]
then
	echo -e "\033[32mCONGRATULATIONS!!\033[0m\t\t You passed this lab!"
else
	echo -e "\033[31m[FAIL]\033[0m\t\t You did NOT pass this lab \033[36m:-(\033[0m"
fi

