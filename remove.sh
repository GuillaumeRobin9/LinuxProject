#!/bin/bash

# remove all users created from accounts.csv file
while read line
do 
  first_name=$(echo "$line" | cut -d';' -f1)
  last_name=$(echo "$line" | cut -d';' -f2)
  username="$(echo $first_name | head -c 1)${last_name}"
  userdel -r $username # remove user and their home directory
  rm -rf /home/shared/$username # remove the directory created for the user
done < accounts.csv

