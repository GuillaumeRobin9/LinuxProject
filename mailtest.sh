#!/bin/bash



sudo mailx -S smtp="$server" -r guirobin37@gmail.com -s "Account creation" -v "$mailAdress" < "Hello, your username is : "$username" and your password is : "$password". Please change your password for security reason. Thank you !"
