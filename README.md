# LinuxProject
L'objectif de ce projet était de créer un script prêt a être déployé peut inporte la machine permettant la création d'utilisateur, une fonction de sauvegarde automatique, 
l'installation d'eclipse et de nextcloud, la modification de règle du pare feu ainsi que le monitoring des ressources utilisé de la machine. 
Ce script permet donc de nombreuse action a travers l'usage d'un serveur distant. 


L'objectif de ce projet était de créer un script prêt à être déployé peu importe la machine, permettant la création d'utilisateurs, une fonction de sauvegarde automatique, l'installation d'Eclipse et de Nextcloud, la modification des règles du pare-feu ainsi que le monitoring des ressources utilisées par la machine. Ce script permet donc de nombreuses actions à travers l'usage d'un serveur distant.
# Préquis 
Le script, s'il est exécuté avec des droits root, sera capable d'installer les dépendances requises par lui-même, telles que snapd, ufw, ou encore sysstat.
# Arguments 
Le script prend 4 arguments :
1. l'adresse du serveur 
2. le nom de l'utilisateur du serveur
3. l'adresse mail emettrice
4. le mot de passe de l'adresse mail emettrice 

 
  # Disclaimer 
  De nombreux élements n'ont pu être testé qu'en local étant donné que lors de la conception je ne possèdais pas les droits d'administrateur du serveur distant. 
