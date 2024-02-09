#!/bin/bash
# 
# created by Sander van Vugt, mail@sandervanvugt.nl
# please send suggestions for improvement to the above email address

clear
ls /root &>/dev/null || (echo run this script with root privileges && exit 2)

####opening a shell as user student for testing 
sudo -u student -i <<HERE

####checking access to a repository 
# setting variables in a here document is not supported, so no grading for this script

if podman login --get-login &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t you are logged in to at least one registry"
else
	echo -e "\033[31m[FAIL]\033[0m\t\t i cannot find any podman login credentials"
	echo -e "Did you use \033[1mpodman login registryname\033[0m to login to the registry?"
fi

####check that mydb is running
if podman ps | grep mydb &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t good! I can find the container mydb. Let's check all required conditions"
	if ls /home/student/mariadb/mysql.sock &>/dev/null
	then
		echo -e "\033[32m[OK]\033[0m\t\t database has been created"
	else
		echo -e "\033[31m[FAIL]\033[0m\t\t the database has not been created"
                echo -e "Did you use the \033[1m:Z\033[0m option while creating the bind mount?"

	fi
	if podman ps | grep mydb | grep 3206 &>/dev/null
	then
	echo -e "\033[32m[OK]\033[0m\t\t container exposed on host port 3206"
        else
                echo -e "\033[31m[FAIL]\033[0m\t\t the container isn't listening on host port 3206"
                echo -e "Did you use the \033[1m-p 3206:3206\033[0m option while running the container"

        fi

else
	echo -e "\033[31m[FAIL]\033[0m\t\t the container mydb was not found"
fi

####closing the user student shell
HERE

####checking the systemd parts
if [ -f /home/student/.config/systemd/user/container-mydb.service ] &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t systemd user unit was found"
else
	echo -e "\033[31m[FAIL]\033[0m\t\t systemd user unit was not found. Check the following:"
	echo -e "-\tuse \033[1mmkdir ~.config/systemd/user\033[0m to create the directory where it must be created"
	echo -e "-\tuse \033[1mpodman generate systemd\033[0m with the appropriate options to generate it"
fi

####checking if the systemd unit is enabled
if ps aux | grep conmon | grep student | grep mydb &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t the container is currently running as a systemd unit"
else
	echo -e "\033[31m[FAIL]\033[0m\t\t the container is not currently running as a systemd unit. Did you use \033[1msystemctl enable --user container-mydb.service\033[0m to enable it?"
fi

