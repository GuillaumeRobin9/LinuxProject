#!/bin/bash

#-------------------------------------------------ACCOUNT CREATION----------------------------
#sed -i 1d accounts.csv # remove first line for Name Surname password etc ..
mkdir /home/shared
chmod +rx /home/shared #loop  for creating user 
while read line
do
  first_name=$(echo "$line" | cut -d';' -f1) # take name column 1
  last_name=$(echo "$line" | cut -d';' -f2) # take surname column 2
  username="$(echo $first_name | head -c 1)${last_name}" # concatenation
  password=$(echo "$line" | cut -d';' -f4) # take password column 4
  mailAdress=$(echo "$line" | cut -d';' -f3) # take mail  column 3
  sudo useradd -p $(openssl passwd -1 $password) $username -m -d /home/shared/$username
  #sudo usermod -p $password $username
  #sudo passwd -e $username # make password expire immediatly
  mkdir /home/shared/$username/a_sauver
  echo "$username"
    # send email to user
    mailx -S smtp=10.30.48.100 -r guirobin37@gmail.com -s "Account creation" -v "$mailAdress" < "Hello, your username is : "$username" and your password is : "$password". Please change your password for security reason. Thank you !"
done < accounts.csv

# ---------------------------------------------------ECPLISE INSTALLATION -------------------------------------------------
# apt install eclipse # ? not with apt ?  

# ---------------------------------------------------PARE FEU ------------------------------------------------------------
sudo apt install ufw -y  # Uncomplicated Firewall
ufw deny ftp
ufw deny udp
