#!/bin/bash
# first draft, pre-test, 3 Feb 2024
# 
# created by Sander van Vugt, mail@sandervanvugt.nl
# please send suggestions for improvement to the above email address

# checking this script runs as root
clear
ls /root &>/dev/null || (echo run this script with root privileges && exit 2)

# cleaning up the exam-report.txt file that may exist from a previous run
rm -f /tmp/exam-report.txt &>/dev/null
touch /tmp/exam-report.txt &>/dev/null

# initializing variables required for evaluation
SCORE=0
TOTAL=0

# checking if SELinux is enforcing
if getenforce | grep -i enforcing &>/dev/null
then
	true
else
	echo -e "\033[31m[FAIL]\033[0m\t\t You have FAILED this mini exam because SELinux is not in enforcing mode. Set SELinux to enforcing mode and try again."
	exit 666
fi


#### TASK 1
echo -e "\033[1mevaluation task 1\033[0m" | tee -a /tmp/exam-report.txt
if ps aux | grep httpd | grep -v grep &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t the httpd service is running"
	SCORE=$(( SCORE + 10 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t I can't find a running httpd process. Did you use \033[1msystemctl enable --now httpd\033[0m to start it?" | tee -a /tmp/exam-report.txt
fi
TOTAL=$(( TOTAL + 10 ))

if curl localhost:82 &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t Your webserver is accepting traffic on port 82"
	SCORE=$(( SCORE + 50 ))
elif grep 'Listen 82' /etc/httpd/conf/httpd.conf &>/dev/null
then
	echo -e "\033[31m[FAIL]\033[0m\t\t You have modified the httpd.conf configuration file, but SELinux doesn't allow access"| tee -a /tmp/exam-report.txt
else
	echo -e "\033[31m[FAIL]\033[0m\t\t You haven't modified the Listen parameter in /etc/httpd/conf/httpd.conf"| tee -a /tmp/exam-report.txt
fi
echo -e "\n"
TOTAL=$(( TOTAL + 50 ))

### task2
# user lori, UID 1100, shell /bin/nologin
echo -e "\033[1mevaluating task 2\033[0m"| tee -a /tmp/exam-report.txt
if id lori &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t User lori exists"
	SCORE=$(( SCORE + 10 ))
	if grep lori /etc/passwd | grep '/sbin/nologin' &>/dev/null
	then
		echo -e "\033[32m[OK]\033[0m\t\t User lori shell set to \033[1m/sbin/nologin\033[0m"
		SCORE=$(( SCORE + 10 ))
	else
		echo -e "\033[31m[FAIL]\033[0m\t\t User lori shell not set to \033[1m/sbin/nologin\033[0m"| tee -a /tmp/exam-report.txt
	fi
	if grep lori /etc/passwd | grep 1100 &>/dev/null
	then
		echo -e "\033[32m[OK]\033[0m\t\t User lori UID set to 1100"
		SCORE=$(( SCORE + 10 ))
	else
		echo -e "\033[31m[FAIL]\033[0m\t\t User lori UID not set to 1100"| tee -a /tmp/exam-report.txt
	fi
else
	echo -e "\033[31m[FAIL]\033[0m\t\t User lori doesn't exist"| tee -a /tmp/exam-report.txt
fi
TOTAL=$(( TOTAL + 30 ))


###task 3
#/tmp/stratorfiles.txt
echo -e "\033[1mevaluating task 3\033[0m"| tee -a /tmp/exam-report.txt
if [ -f /tmp/stratorfiles.txt ]
then
	echo -e "\033[32m[OK]\033[0m\t\t File /tmp/stratorfiles.txt was found"
	SCORE=$(( SCORE + 10 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t File /tmp/stratorfiles.txt was not found"| tee -a /tmp/exam-report.txt
fi

if grep '/etc/services' /tmp/stratorfiles.txt &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t /tmp/stratorfiles.txt content looking all right"
	SCORE=$(( SCORE + 10 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t /tmp/stratorfiles.txt content not looking good"| tee -a /tmp/exam-report.txt
fi
TOTAL=$(( TOTAL + 20 ))


###task 4
echo -e "\033[1mevaluating task 4\033[0m"| tee -a /tmp/exam-report.txt
if ls -l /tmp/hosts | grep -- '->' &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t symbolic link /tmp/hosts was found"
        SCORE=$(( SCORE + 10 ))
else
        echo -e "\033[31m[FAIL]\033[0m\t\t symbolic link /tmp/hosts was not found"| tee -a /tmp/exam-report.txt
fi
TOTAL=$(( TOTAL + 10 ))

###task 5
echo -e "\033[1mevaluating task 5\033[0m"| tee -a /tmp/exam-report.txt
# create group sales
# check directory /data/sales, groupownership on that directory and SGID permission
if grep sales /etc/group &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t group sales was found"
        SCORE=$(( SCORE + 10 ))
else
        echo -e "\033[31m[FAIL]\033[0m\t\t group sales was not found"| tee -a /tmp/exam-report.txt
fi
TOTAL=$(( TOTAL + 10 ))

if [ -d /data/sales ]
then
	if [[ $(ls -ld /data/sales | awk '{ print $4 }') == sales ]]
	then
		echo -e "\033[32m[OK]\033[0m\t\t \033[1m/data/sales\033[0m is group-owned by group sales"
        	SCORE=$(( SCORE + 10 ))
	else
		echo -e "\033[31m[FAIL]\033[0m\t\t \033[1m/data/sales\033[0m is not group-owned by group sales"| tee -a /tmp/exam-report.txt
	fi
	if [ -g /data/sales ]
	then
		echo -e "\033[32m[OK]\033[0m\t\t \033[1m/data/sales\033[0m has the SGID permission"
		SCORE=$(( SCORE + 10 ))
	else
		echo -e "\033[31m[FAIL]\033[0m\t\t \033[1m/data/sales\033[0m doesn't have the SGID permission"| tee -a /tmp/exam-report.txt
	fi
else
	echo -e "\033[31m[FAIL]\033[0m\t\t \033[1m/data/sales\033[0m doesn't exist"| tee -a /tmp/exam-report.txt
fi
TOTAL=$(( TOTAL + 30 ))


###task 6
echo -e "\033[1mevaluating task 6\033[0m"| tee -a /tmp/exam-report.txt
# create an LVM volume lvlab
if lvs | grep lvlab &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t logical volume lvlab was found"
	SCORE=$(( SCORE + 10 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t logical volume lvlab was not found. Please make sure you master this topic, it is very important and you probably fail the exam if you can't manage LVM."| tee -a /tmp/exam-report.txt
fi

# check if it has a 50 extent size
if [[ $(lvdisplay | grep -A 11 '\blvlab' | awk '/Current LE/ { print $3 }') == 50 ]]
then
	echo -e "\033[32m[OK]\033[0m\t\t lvlab has a size of 50 extents"
	SCORE=$(( SCORE + 10 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t lvlab size is not 50 extents"| tee -a /tmp/exam-report.txt
fi

# format with xfs
if blkid $(ls /dev/mapper/* | grep lvlab) | grep xfs &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t lvlab is formatted with xfs"
	SCORE=$(( SCORE + 10 ))
else	
	echo -e "\033[31m[FAIL]\033[0m\t\t no xfs found on lvlab"| tee -a /tmp/exam-report.txt
fi

# mount peristently on /lvlab
if ls /run/systemd/generator/ | grep lvlab &>/dev/null || ls /etc/systemd/system/ | grep lvlab &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t persistent mount configuration was found"
	SCORE=$(( SCORE + 10 ))
	if grep lvlab /etc/fstab &>/dev/null
	then
		true
	else
		echo -e "\e[5m\033[32m[AWESOME]\033[0m\e[0m\t\t you earned 10 bonus points for mounting through systemd only"| tee -a /tmp/exam-report.txt
		SCORE=$(( SCORE + 10 ))
	fi
else
	echo -e "\033[31m[FAIL]\033[0m\t\t no persistent mount configuration was found"| tee -a /tmp/exam-report.txt
fi

## check if it is mounted now
if mount | grep lvlab &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t lvlab was found as mounted"
	SCORE=$(( SCORE + 10 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t lvlab is not currently mounted"| tee -a /tmp/exam-report.txt
fi

## check for noexec mount option
if mount | grep lvlab | grep noexec &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t the \033[1mnoexec\033[0m mount option was used"
	SCORE=$(( SCORE + 10 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t you have not used the \033[1mnoexec\033[0m mount option, so executables can still be started from this volume"| tee -a /tmp/exam-report.txt
fi
TOTAL=$(( TOTAL + 60 ))

###task 7
echo -e "\033[1mevaluating task 7\033[0m"| tee -a /tmp/exam-report.txt
if [[ $(tuned-adm active 2>/dev/null | tail -1 | awk '{ print $3 }') == $(tuned-adm recommend 2>/dev/null) ]]
then
	echo -e "\033[32m[OK]\033[0m\t\t the recommended tuned profile matches the current tuned profile"
        SCORE=$(( SCORE + 10 ))
else
        echo -e "\033[31m[FAIL]\033[0m\t\t the recommended tuned profile doesn't match the current tuned profile"| tee -a /tmp/exam-report.txt
fi
TOTAL=$(( TOTAL + 10 ))

### FINAL GRADING
echo press enter to get a results overview
read
clear 
grep FAIL /tmp/exam-report.txt &>/dev/null || echo no errors were found in your solutions >> /tmp/exam-report.txt 
cat /tmp/exam-report.txt
echo press enter to get your final score
read
clear
echo -e "\n"
echo -e "\033[1myour total score is $SCORE out of a total of $TOTAL\033[0m"

if [[ $SCORE -ge $(( TOTAL / 10 * 7 )) ]]
then
	echo -e "\033[32mCONGRATULATIONS!!\033[0m\t\t You passed this final minitest! This is NO guarantee that you'll pass the real thing, but at least you're on the right track!"
else
	echo -e "\033[31m[FAIL]\033[0m\t\t You did NOT pass this final minitest. Carefully study topics in https://learning.oreilly.com/videos/-/9780137931521/ before taking the exam."
fi
