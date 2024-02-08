#!/bin/bash
# 
# created by Sander van Vugt, mail@sandervanvugt.nl
# please send suggestions for improvement to the above email address

clear
ls /root &>/dev/null || (echo run this script with root privileges && exit 2)

SCORE=0

####check if an LV with the name lvdb and a size of 1 GiB was found 
if lvs | grep lvdb &>/dev/null
then
	SCORE=$(( SCORE + 10 ))
	echo -e "\033[32m[OK]\033[0m\t\t found the logical volume lvdb"
	if lvs | grep lvdb | grep 1020 &>/dev/null
	then
		echo -e "\033[32m[OK]\033[0m\t\t verified that lvdb size is 1020MiB"
		SCORE=$(( SCORE + 10 ))
	else
		echo -e "\033[31m[FAIL]\033[0m\t\t the logical volume lvdb exists, the size is not correct. continuing evaulation"
	fi
else
	echo -e "\033[31m[FAIL]\033[0m\t\t logical volume \033[1mlvdb\033[0m not found"
	echo -e "Check that you have done the following to create it"
	echo -e "-\tcreate a 1GiB partition and mark it with partition type 82"
	echo -e "-\tuse \033[1mvgcreate vgdb /dev/sdxy\033[0m to create the volume group"
	echo -e "-\tuse \033[1mlvcreate -n lvdb -L 1G vgdb\033[0m to create the logical volume"
	echo -e "\033[34mexiting now, please try again\033[0m"
	exit 2
fi
TOTAL=20

###check if lvdb is formatted with XFS and mounted on /mounts/lvdb
if lsblk | grep lvdb | grep '/mounts/lvdb' &>/dev/null
then
        echo -e "\033[32m[OK]\033[0m\t\t the logical volume lvdb is successfully mounted on /mounts/lvdb"
	SCORE=$(( SCORE + 10 ))
else
        echo -e "\033[31m[FAIL]\033[0m\t\t the logical volume lvdb exists, but it isn't mounted on /mounts/lvdb. Check the following:"
	echo -e "-\tdid you use \033[1mmkdir -p /mounts/lvdb\033[0m to create the mount point?"
	echo -e "-\tdid you use \033[1mount -a\033[0m to mount all filesystems not currently mounted?"
fi
TOTAL=$(( TOTAL + 10 ))

###check if persistent xfs mount is in /etc/fstab
if grep '/mounts/lvdb' /etc/fstab | grep xfs &>/dev/null
then
        echo -e "\033[32m[OK]\033[0m\t\t \033[1m/etc/fstab\033[0m contains a line that persistently mounts the LV as an XFS filesystem"
	SCORE=$(( SCORE + 10 ))
else
        echo -e "\033[31m[FAIL]\033[0m\t\t \033[1m/etc/fstab\033[0m doesn't contain a line that persistently mounts the logical volumeas an xfs filesystem on \033[1m/mounts/lvdb\033[0m"
fi
TOTAL=$(( TOTAL + 10 ))

###check if there are two PVs behind the root volume, of which the second one if 5 GiB
if lvdisplay | grep -A9 'LV Name.*root' | tail -1 | grep 2 &>/dev/null
then
        echo -e "\033[32m[OK]\033[0m\t\t the root logical volume is based on 2 PVs"
	SCORE=$(( SCORE + 10 ))
else
        echo -e "\033[31m[FAIL]\033[0m\t\t the root logical volume in not based on 2 PVs. Check the following:"
	echo -e "-\tyou have added a partition and this is available as a pv. Use \033[1mpvs\033[0m to verify"
	echo -e "-\tthe existing root volume was resized using \033[1mlvresize\033[0m"
fi
TOTAL=$(( TOTAL + 10 ))

#### finding the VG where the root LV is created
ROOTVG=$(lvdisplay | grep -A1 'LV Name.*root' | tail -1 | awk '{ print $3 }')
#### checking if $ROOTVG has a PV with a size of 5.0
if pvs | awk -v val="$ROOTVG" '$0 ~ val { print $5 }' | grep '5.0' &>/dev/null
then
	echo -e "\033[32m[OK]\033[0m\t\t found one of the root lv pv's with a size of 5 GiB"
	SCORE=$(( SCORE + 10 ))
else
	echo -e "\033[31m[FAIL]\033[0m\t\t if found 2 PVs in the root lv, but not with the expected size of 5 GiB"
fi
TOTAL=$(( TOTAL + 10 ))

echo -e "\n"
echo your score is $SCORE out of a total of $TOTAL

if [[ $SCORE -ge $(( TOTAL / 10 * 7 )) ]]
then
	echo -e "\033[32mCONGRATULATIONS!!\033[0m\t\t You passed this lab!"
else
	echo -e "\033[31m[FAIL]\033[0m\t\t You did NOT pass this lab \033[36m:-(\033[0m"
fi



