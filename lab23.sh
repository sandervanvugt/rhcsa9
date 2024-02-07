#!/bin/bash

if [ -z $1 ]
then
	echo you need to specify a directory name as argument
	exit 9
fi

for i in $1/*.txt
do
	cp $i $i.bak
	mv $i.bak /tmp
done
