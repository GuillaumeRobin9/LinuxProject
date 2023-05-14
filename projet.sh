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
  sudo useradd -p $(openssl passwd -1 $password) $username -m -d /home/$username
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
sudo tar -czf "/home/Atiffany/save_Atiffany.tgz"  --directory="/home/Atiffany/a_sauver" . 

# tar -zcvf /home/shared/$USERNAME/a_sauver_$USERNAME.tgz /home/shared/$USERNAME/a_sauver # localisation destination 
# server version with ssh
ssh grobin25@10.30.48.100 'tar -zcvf /home/shared/$USERNAME/a_sauver_$USERNAME.tgz /home/shared/$USERNAME/a_sauver' # localisation destination
ssh grobin25@10.30.48.100 'tar tar czf - /home/shared/$USERNAME/a_sauver_$USERNAME.tgz' | tar xvzf - -C /home/username  # localisation destination



# ---------------------------------------------------ECPLISE INSTALLATION -------------------------------------------------
wget -P eclipse/test https://rhlx01.hs-esslingen.de/pub/Mirrors/eclipse/oomph/epp/2023-03/R/eclipse-inst-jre-linux64.tar.gz
tar -xvzf eclipse-inst-jre-linux64.tar.gz -C eclipse/
sudo ln -s  /chemin/vers/destination/eclipse-latest eclipse # symbolic link to make it accessible to all user

# ---------------------------------------------------PARE FEU ------------------------------------------------------------
sudo apt install ufw -y  # Uncomplicated Firewall
ufw deny ftp
ufw deny udp

# ---------------------------------------------------NEXTCLOUD------------------------------------------------------------
#local 
wget https://download.nextcloud.com/server/releases/nextcloud-22.0.0.zip # download nextcloud
sudo apt install unzip -y # install unzip
sudo apt-get install apache2 mariadb-server libapache2-mod-php7.4 \
  php7.4-gd php7.4-json php7.4-mysql php7.4-curl \
  php7.4-intl php7.4-mbstring php7.4-xml php7.4-zip \
  php7.4-bz2 php-apcu redis-server -y # install all dependencies
unzip nextcloud-22.0.0.zip # unzip nextcloud
sudo mv nextcloud /var/www/html/ # move nextcloud to apache2 folder
sudo chown -R www-data:www-data /var/www/html/nextcloud/ # change owner of nextcloud folder
sudo apt install mariadb-server mariadb-client -y # install mariadb needed bc postgresql is not supported by nextcloud
sudo service mariadb start # start mysql
sudo a2enmod php7.4
sudo service apache2 restart # start apache2
# create database and user in MYSQL 
sudo mysql
create database nextcloud;
create user nextcloud-admin identified by N3x+_Cl0uD;
grant all privileges on nextcloud.* to nextcloud-admin identified by N3x+_Cl0uD;
flush privileges;
exit;

ssh -L 4242:localhost:80 nextcloud-admin@10.30.48.100



#sudo -u www-data php /var/www/html/nextcloud/occ user:add --display-name="nextcloud-admin" --group="admin" nextcloud-admin N3x+_Cl0uD # create admin user


#server
#wget https://download.nextcloud.com/server/releases/nextcloud-22.0.0.zip
#sudo apt install unzip -y
#sudo scp 'nextcloud-22.0.0.zip' grobin25@10.30.48.100:/home/grobin25
#ssh grobin25@10.30.48.100 "unzip /home/grobin25/nextcloud-22.0.0.zip"
#ssh grobin25@10.30.48.100 "./home/grobin25/nextcloud-22.0.0.zip"


