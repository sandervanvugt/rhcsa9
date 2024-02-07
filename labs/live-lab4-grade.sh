#!/bin/bash
# 
# created by Sander van Vugt, mail@sandervanvugt.nl
# please send suggestions for improvement to the above email address

clear
ls /root &>/dev/null || (echo run this script with root privileges && exit 2)

SCORE=0

#!/bin/bash

### check if a second disk was found and print its name
SECOND_DISK=$(lsblk | grep disk | sed -n '2p' | awk '{ print $1 }')

echo -e "\033[33m[NOTICE]\033[0m\t this script has been tested on second disks using the device name /dev/sdb or /dev/nvme0n2. It may fail if your second disk has another name" 

if [ -z $SECOND_DISK ]
then
	echo -e "\033[31m[FAIL]\033[0m\t\t No second disk was found. Do you manually want to set the name of the second disk? (yes/no)"
	read ANSWER
	if [ $ANSWER = yes ]
	then
		echo -e "enter the second disk name. (Do NOT include /dev/ in the name - \033[1msdb\033\0m and not \033[1m/dev/sdb]033\0m)"
		read SECOND_DISK
	else
		echo OK, exiting now
		exit 62
	fi
else
	echo -e "\033[32m[OK]\033[0m\t\t The second disk is ${SECOND_DISK}. Using this for the rest of the evaluation"
fi

# at this point the second disk is either sdb or nvme0n2. As partitions are named differently, we define a variable $PARTITION
# this allows us to futher add the partition number in a uniform way
[ $SECOND_DISK = sdb ] && PARTITION=sdb
[ $SECOND_DISK = nvme0n2 ] && PARTITION=nvme0n2p

echo the partition base is $PARTITION and the first partition is ${PARTITION}1

#### verify that a partition with a size of 1GB was found
if [[ $(lsblk | grep ${PARTITION}1 | awk '{ print $4 }') == "1G" ]]
then
	echo -e "\033[32m[OK]\033[0m\t\t a partition with a size of 1GB was found."
else
	echo -e "\033[31m[FAIL]\033[0m\t\t The second disk doesn't contain a partition with a size of 1GB. Exiting now."
	exit 61
fi

#### verifying that ${PARTITION}1 is mounted persistently using the blkid
# check that ${PARTITION}1 is formatted with ext4

if blkid /dev/${PARTITION}1 | grep ext4 &>/dev/null
then
        echo -e "\033[32m[OK]\033[0m\t\t found an ext4 filesystem on ${PARTITION}1"
else
        echo -e "\033[31m[FAIL]\033[0m\t\t couldn't find and ext4 filesystem on ${PARTITION}1. Exiting now."
        exit 63
fi

# detect ${PARTITION}1 blkid and store in variable P1UUID
P1UUID=$(blkid /dev/${PARTITION}1 | awk '{ print $2 }' | cut -d = -f 2)
P1UUID=$(echo $P1UUID | sed 's/"//g')
#echo DEBUGGING: P1UUID is now set to $P1UUID

# check mount output to verify that $P1UUID is currently mounted on /mounts/files

if mount | grep ${PARTITION}1 &>/dev/null
then
        echo -e "\033[32m[OK]\033[0m\t\t the partition is currently mounted on /mounts/files"
else
        echo -e "\033[31m[FAIL]\033[0m\t\t the partition is not currently mounted on /mounts/files. Did you use \033[1mmkdir -p /mounts/files\033[0m to create it?"
fi
# grep /etc/fstab to verify that it contains a line that has $BLKID

if grep $P1UUID /etc/fstab | grep '/mounts/files' &>/dev/null
then
        echo -e "\033[32m[OK]\033[0m\t\t I have found the mount by UUID in /etc/fstab"
else
        echo -e "\033[31m[FAIL]\033[0m\t\t Can't find the mount by UUID in /etc/fstab"
fi

#### evaluating the next part
# check if we have an extended partition ${PARTITION}2 that is using all remaining disk space
if fdisk -l /dev/${SECOND_DISK} | grep ${PARTITION}2 | grep Extended &>/dev/null
then
	PARTSIZE=$(fdisk -l /dev/$SECOND_DISK | grep -A 3 '^Device' | sed -n '3p' | awk '{ print $3 }')
	if [[ $(fdisk -l /dev/sdb | sed -n '1p' | awk '{ print $7 }') == $(( PARTSIZE + 1 )) ]]
	then
		echo -e "\033[32m[OK]\033[0m\t\t an extended partition that uses all remaining disk space was found"
	else
		echo -e "\033[31m[FAIL]\033[0m\t\t the extended partition was found, but it doesn't use all remaining disk space"
	fi
else
	echo -e "\033[31m[FAIL]\033[0m\t\t no extended partition was found"
fi

# check if we have a logical partition ${PARTITION}5 with a size of 500MiB
if [[ $(fdisk -l /dev/sdb | awk '/sdb5/ { print $5 }') == 500M || $(fdisk -l /dev/nvme0n2 | awk '/nvme0n2p5/ { print $5 }') == 500M ]]
then
	echo -e "\033[32m[OK]\033[0m\t\t I have found a logical partition with a size of 500MiB"
else
	echo -e "\033[31m[FAIL]\033[0m\t\t I haven't found a logical partition with a size of 500MiB"
fi


# check that the logical partition has the label myxfs
if blkid | grep ${PARTITION}5 | grep myxfs &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t the logical partition uses the label myxfs"
else
        echo -e "\033[31m[FAIL]\033[0m\t\t the logical partition doesn't use the label myxfs"
fi

# check that there is a persistent mount that uses this label
if grep myxfs /etc/fstab &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t a persistent mount for the label myxfs was found"
else
        echo -e "\033[31m[FAIL]\033[0m\t\t /etc/fstab doesn't contain a mount for the label myxfs"
fi

# check that a 500MiB swap partition was created
if [ $SECOND_DISK = sdb ]
then
	if [[ $(fdisk -l /dev/sdb | awk '/sdb6/ { print $5 }') == 500M && $(fdisk -l /dev/sdb | awk '/sdb6/ { print $8 }') == swap ]]
	then
       		echo -e "\033[32m[OK]\033[0m\t\t found a 500MiB swap partition"
	else
        	echo -e "\033[31m[FAIL]\033[0m\t\t couldn't find a 500MiB swap partition. Did you set the partition type to swap?"
	fi
elif [ $SECOND_DISK = nvme0n2 ]
	then
        if [[ $(fdisk -l /dev/nvme0n2 | awk '/nvme0n2p6/ { print $5 }') == 500M && $(fdisk -l /dev/nvme0n2 | awk '/nvme0n2p6/ { print $8 }') == swap ]]
        then
                echo -e "\033[32m[OK]\033[0m\t\t found a 500MiB swap partition"
        else
                echo -e "\033[31m[FAIL]\033[0m\t\t couldn't find a 500MiB swap partition. Did you set the partition type to swap?"
        fi
fi



# check that the 500MiB swap partition is actually used
if swapon -s | grep ${PARTITION}6 &>/dev/null
then
        echo -e "\033[32m[OK]\033[0m\t\t confirmed that the swap partition is used"
else
        echo -e "\033[31m[FAIL]\033[0m\t\t the swap partition is not currently used. Did you use \033[1mmkswap\033[0m to format it and \033[1mswapon\033[0m to mount it?"
fi
