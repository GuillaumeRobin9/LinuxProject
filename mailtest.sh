#!/bin/bash

# Installation de sysstat
sudo apt-get install sysstat -y

# Récupération de la date et de l'heure actuelles
timestamp=$(date +"%Y%m%d_%H%M%S")

# Surveillance des ressources et enregistrement dans des fichiers
echo "CPU Monitoring."
mpstat -P ALL > monitoring_cpu_$timestamp.txt
echo "Network Monitoring."
sar -n DEV 1 1 > monitoring_network_$timestamp.txt
