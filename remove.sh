#!/bin/bash

# remove all users created from accounts.csv file
while IFS=';' read -r name surname mail password
do
  first_name=$(echo "$name" | cut -d' ' -f1)
  last_name=$(echo "$surname" | cut -d' ' -f2)
  username="$(echo $first_name | head -c 1)${last_name}"
  userdel -r $username # remove user and their home directory
done < accounts.csv
