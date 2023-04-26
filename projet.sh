#!/bin/bash


##-------------------------------------------------VARIABLE SETTING-----------------------------
SMTP_SERVER="your_smtp_server"
SMTP_LOGIN="your_smtp_login"
SMTP_PASSWORD="your_smtp_password"

#-------------------------------------------------ACCOUNT CREATION----------------------------
#sed -i 1d accounts.csv # remove first line for Name Surname password etc ..
mkdir /home/shared
chmod +rx /home/shared #loop  for creating user 
while read line
do
  first_name=$(echo "$line" | cut -d';' -f1) # take name column 1
  last_name=$(echo "$line" | cut -d';' -f2) # take surname column 2
  #username="$(echo $first_name | head -c 1)${last_name}" # concatenation
  username=$(echo $first_name $last_name | tr '[:upper:]' '[:lower:]' | tr -d ' ' | cut -c1-8) # concatenation
  password=$(echo "$line" | cut -d';' -f4) # take password column 4
  echo "$username:$password" | chpasswd 
  sudo useradd $username -m -d /home/shared/$username
  sudo passwd --expire $username # make password expire immediatly
  mkdir /home/shared/$username/a_sauver
  echo "$username"
    # send email to user
    EMAIL_SUBJECT="Welcome to Linux Project $HOSTNAME"
    EMAIL_BODY="Your acccount as succesfully been created, thank you ! For security reason, please change your password" 
done < accounts.csv













# ---------------------------------------------------ECPLISE INSTALLATION -------------------------------------------------
# apt install eclipse # ? not with apt ?  

# ---------------------------------------------------PARE FEU ------------------------------------------------------------
sudo apt install ufw -y  # Uncomplicated Firewall
ufw deny ftp
ufw deny udp
