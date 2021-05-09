#!/usr/bin/env bash

SitePath="/var/www/Django-App"
App="Django-App"
VH="djangoapp"

# Install Python3.9 & Django
# --------------------------------
sudo apt update
# sudo apt upgrade -y
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install apache2 python3.9 -y
sudo apt install libapache2-mod-wsgi-py3 -y
sudo apt install python3-pip -y
sudo python3 -m pip install Django

# Configuración del sitio virtual para Python
echo "<VirtualHost *:80>
        DocumentRoot $SitePath
        WSGIDaemonProcess $App user=www-data group=www-data processes=1 threads=5 python-path=$SitePath
        WSGIScriptAlias / $SitePath/djangoapps/wsgi.py
        <Directory $SitePath>
                WSGIProcessGroup $App        
                WSGIApplicationGroup %{GLOBAL}
                Require all granted
        </Directory>
        ErrorLog \${APACHE_LOG_DIR}/$VH-error.log
        CustomLog \${APACHE_LOG_DIR}/$VH-access.log combined
</VirtualHost>" | sudo tee /etc/apache2/sites-available/$VH.conf > /dev/null

sudo a2ensite $VH.conf
sudo a2dissite 000-default.conf
sudo service apache2 restart