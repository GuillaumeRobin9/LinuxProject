#!/bin/bash
#-------------------------------------------------VARIABLE DECLARATION----------------------------

SMTPServer="10.30.48.100" 
SMTPLogin="SMTP_login" 
SMTPPassword="SMTP_password" 

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
  sudo passwd -e $username # make password expire immediatly
  mkdir /home/shared/$username/a_sauver_$username # create folder for backup
  echo "$username"
    # send email --> local version 
    echo "Your account as succesfully been created. You are $username and your password is : $password. Please change your password for security reason. Thank you !" | mail -s "this is an automatically generated email please do not reply" guillaume.robin@isen-ouest.yncrea.fr
    # send email --> server version
    echo "Your account as succesfully been created. You are $username and your password is : $password. Please change your password for security reason. Thank you !" | mailx -v -r "$mailAdress" -s "this is an automatically generated email please do not reply" -S smtp="$SMTPServer" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$SMTPLogin" -S smtp-auth-password="$SMTPPassword" -S ssl-verify=ignore "$mailAdress"

done < accounts.csv

# ----------------------------------------------------------SAUVEGARDE------------------------------------------- 
#local version
tar -zcvf /home/shared/$USERNAME/a_sauver_$USERNAME.tgz /home/shared/$USERNAME/a_sauver # localisation destination 
# server version with ssh
ssh grobin25@10.30.48.100 'tar -zcvf /home/shared/$USERNAME/a_sauver_$USERNAME.tgz /home/shared/$USERNAME/a_sauver' # localisation destination
ssh grobin25@10.30.48.100 'tar tar czf - /home/shared/$USERNAME/a_sauver_$USERNAME.tgz' | tar xvzf - -C /home/username  # localisation destination
#ssh grobin25@10.30.48.100 'tar -zcvf /home/shared/myusername/a_sauver_myusername.tgz /home/shared/myusername/a_sauver'


# ---------------------------------------------------ECPLISE INSTALLATION -------------------------------------------------
wget -P eclipseTest https://www.eclipse.org/downloads/download.php?file=/oomph/epp/2023-03/R/eclipse-inst-jre-linux64.tar.gz

# ---------------------------------------------------PARE FEU ------------------------------------------------------------
sudo apt install ufw -y  # Uncomplicated Firewall
ufw deny ftp
ufw deny udp
