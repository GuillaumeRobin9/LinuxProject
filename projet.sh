#!/bin/bash
#-------------------------------------------------ARGUMENTS DECLARATION----------------------------

SSH_server=$1
SSH_username=$2
#SMTPLogin=$3
#SMTPPassword=$4

#argument escape needed bc of special characters in password and @ in mail adress
SMTPLogin=$(echo $3 | sed 's/\@/\\\@/g') 
SMTPPassword=$(echo $4 | sed 's/\ /\\\ /g')
SMTPPassword=$(echo $4 | sed 's/\$/\\\$/g')
SMTPPassword=$(echo $4 | sed 's/\~/\\\~/g')
SMTPPassword=$(echo $4 | sed 's/\&/\\\&/g')
SMTPPassword=$(echo $4 | sed 's/\@/\\\@/g')
SMTPPassword=$(echo $4 | sed 's/\!/\\\!/g')



#-------------------------------------------------ACCOUNT CREATION----------------------------
#sed -i 1d accounts.csv # remove first line for Name Surname password etc ..
mkdir /home/shared
chmod +rx /home/shared 
#loop  for creating user 
while read line
do
  first_name=$(echo "$line" | cut -d';' -f1) # take name column 1
  last_name=$(echo "$line" | cut -d';' -f2) # take surname column 2
  username="$(echo $first_name | head -c 1)${last_name}" # concatenation
  password=$(echo "$line" | cut -d';' -f4) # take password column 4
  mailAdress=$(echo "$line" | cut -d';' -f3) # take mail  column 3
  sudo useradd -p $(openssl passwd -1 $password) $username -m -d /home/$username 2>/dev/null # no error message
  sudo passwd -e $username 2>/dev/null # make password expire immediatly 
  mkdir /home/$username/a_sauver_$username 2>/dev/null # create folder for backup
  echo "$username"
    # send email --> local version 
    echo "Your account as succesfully been created. You are $username and your password is : $password. Please change your password for security reason. Thank you !" | mail -s "this is an automatically generated email please do not reply" guillaume.robin@isen-ouest.yncrea.fr
    # send email --> server version
    sudo ssh $SSH_username@$SSH_server 'mail --subject "Please do not reply" --exec "set sendmail=smtp://$SMTPLogin:$SMTPPassword;@smtp-mail.outlook.com:587" --append "From:$SMTPLogin" $mailAdress <<< "Your account as succesfully been created. You are $username and your password is : $password. Please change your password for security reason. Thank you !"' 2>/dev/null
done < accounts.csv

# ----------------------------------------------------------SAUVEGARDE------------------------------------------- 
while read line
do
  first_name=$(echo "$line" | cut -d';' -f1) # take name column 1
  last_name=$(echo "$line" | cut -d';' -f2) # take surname column 2
  username="$(echo $first_name | head -c 1)${last_name}" # concatenation
crontab -l > provCron
#echo new cron into cron file
echo "0 23 * * 1-5 tar -czf \"/home/save_$username.tgz\" --directory=\"/home/$username/a_sauver_$username\" . ssh $SSH_username@$SSH_server \"rm -rf /home/saves/save_$username.tgz\" scp /home/save_$username.tgz $SSH_username@$SSH_server:/home/saves/">> provCron
#install new cron file
crontab provCron
rm provCron
done < accounts.csv

#contenu du cron
#sudo tar -czf "/home/save_$username.tgz"  --directory="/home/$username/a_sauver_$username" .
#ssh $SSH_username@$SSH_server "rm -rf /home/saves/save_$username.tgz"
#scp /home/save_$username.tgz $SSH_username@$SSH_server:/home/saves/
#Example

#Save restauration 
cat <<EOF >/home/retablir_sauvegarde
#!/bin/sh

username=$(whoami)

# get save from server
sudo scp -p $SSH_username@$SSH_server:/home/save_$username.tgz /home/$username/a_sauver_$username\save_$username.tgz 2> /dev/null

rm -rf /home/$username/a_sauver_$username/*

tar -xzf /home/$username/save_$username.tgz --directory=/home/$username/a_sauver_$username .

rm /home/$username/save_$username.tgz
EOF


# ---------------------------------------------------ECPLISE INSTALLATION -------------------------------------------------
wget -P /home  https://rhlx01.hs-esslingen.de/pub/Mirrors/eclipse/oomph/epp/2023-03/R/eclipse-inst-jre-linux64.tar.gz
cd /home
sudo tar -xvzf eclipse-inst-jre-linux64.tar.gz 
sudo rm -rf  eclipse-inst-jre-linux64.tar.gz
ln -s /usr/local/share/eclipse/eclipse /usr/local/bin/eclipse # symbolic link to make it accessible to all user

# ---------------------------------------------------PARE FEU ------------------------------------------------------------
sudo apt install ufw -y  # Uncomplicated Firewall

sudo ufw enable 

sudo ufw deny ftp

sudo ufw deny udp

sudo ufw reload 

# ---------------------------------------------------NEXTCLOUD------------------------------------------------------------
#OLD WAY 
#sudo ssh $SSH_username@$SSH_server 'wget https://download.nextcloud.com/server/releases/nextcloud-22.0.0.zip && sudo apt install unzip -y && sudo apt-get install apache2 mariadb-server libapache2-mod-php7.4 php7.4-gd php7.4-json php7.4-mysql php7.4-curl php7.4-intl php7.4-mbstring php7.4-xml php7.4-zip php7.4-bz2 php-apcu redis-server -y && unzip nextcloud-22.0.0.zip && sudo mv nextcloud /var/www/html/ && sudo chown -R www-data:www-data /var/www/html/nextcloud/ && sudo apt install mariadb-server mariadb-client -y && sudo service mariadb start && sudo a2enmod php7.4 && sudo service apache2 restart && sudo mysql -e "CREATE DATABASE nextcloud; CREATE USER 'nextcloud-admin' IDENTIFIED BY 'N3x+_Cl0uD'; GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud-admin' IDENTIFIED BY 'N3x+_Cl0uD'; FLUSH PRIVILEGES;"'
#ssh -L 4242:localhost:80 $SSH_username@$SSH_server > /home/nextcloud_tunneling # tunneling

#Better way with snap 
sudo ssh $SSH_username@$SSH_server 'apt install snapd -y'
sudo ssh $SSH_username@$SSH_server 'snap install nextcloud'
sudo ssh $SSH_username@$SSH_server 'nextcloud.manual-install nextcloud-admin N3x+_Cl0uD'
sudo ssh $SSH_username@$SSH_server 'sudo -u www-data php occ user:add'


# ---------------------------------------------------MONITORING------------------------------------------------------------

ssh $SSH_username@$SSH_server 'sudo apt install net-tools -y' # if config needed for network usage
ssh $SSH_username@$SSH_server 'cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
memory_usage=$(free | grep Mem | awk '{printf "%.2f", $3/$2 * 100}')
network_interface=$(ifconfig | awk '/^[a-z]/ {interface=$1} /inet / {print interface}')
network_usage=$(ifconfig "$network_interface" | awk '/RX packets/ {print $6}')
echo "CPU Usage: $cpu_usage%"
echo "Memory Usage: $memory_usage%"
echo "Network Usage: $network_usage"'

# more detailled CPU prompt but don't show memory usage
sudo apt-get install sysstat -y # install sysstat
mpstat -P ALL # cpu usage
# mpstat -A # more information
