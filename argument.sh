#!/bin/bash

echo you have typed $1 as the first argument
echo there are other arguments as well, these are all arguments: $@

echo what is your name
read NAME
echo your name is $NAME
