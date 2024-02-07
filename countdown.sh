#!/bin/bash

if test -z $1
then
	echo provide number of minutes
	read COUNTER
else
	COUNTER=$1
fi

COUNTER=$(( COUNTER * 60 ))

while [ $COUNTER -gt 0 ]
do
	echo $1 seconds remaining
	COUNTER=$(( COUNTER - 1 ))
	sleep 1
done

echo break is over, continuing
