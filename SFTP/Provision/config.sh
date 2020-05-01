#!/usr/bin/env bash

VerifyPack=$(dpkg -l | grep openssh-server)
User1="usuario1"
User2="usuario2"
Pass="1234"
Group="sftp"
Container="/home/sftp"

if [[ $VerifyPack == "" ]]; then
    sudo apt update -y
    sudo apt install openssh-server -y
fi

# Crear la estructura de directorios
sudo mkdir -p $Container
sudo mkdir -p $Container/$User1
sudo mkdir -p $Container/$User2

# Crear grupo que contendrá los usuarios del servidor SFTP
sudo groupadd $Group

# Crear los usuario
sudo useradd -g $Group -s /bin/false -d $Container/$User1 $User1
sudo useradd -g $Group -s /bin/false -d $Container/$User2 $User2

# Asignar contraseña a los usuarios
echo -e "$Pass\n$Pass\n" | sudo passwd $User1
echo -e "$Pass\n$Pass\n" | sudo passwd $User2

# Asignar permisos para que el directorio sftp pertenezca al usuario root
sudo chown root:root $Container

# Asignar permisos a los usuarios y grupo para los directorios del servidor SFTP
sudo chown $User1:$Group $Container/$User1
sudo chown $User2:$Group $Container/$User2

# Asignar permisos a los directorios
sudo chmod 755 $Container
sudo chmod 755 $Container/$User1
sudo chmod 755 $Container/$User2

#Respaldar el fichero de configuración
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Configuración de SFTP
# Configuración para enjaular a un grupo de usuarios
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/Subsystem/# Subsystem/g' /etc/ssh/sshd_config
sudo sed -i '$a Subsystem sftp internal-sftp' /etc/ssh/sshd_config
sudo sed -i '$a Match group '"$Group"'' /etc/ssh/sshd_config
sudo sed -i '$a ChrootDirectory '"$Container"'' /etc/ssh/sshd_config
sudo sed -i '$a ForceCommand internal-sftp' /etc/ssh/sshd_config
sudo service ssh restart

# Configuración para enjaular usuarios individualmente
#-----------------------------------------------------
# Subsystem sftp internal-sftp
# Match user usuario1
# ChrootDirectory /home/sftp/usuario1
# ForceCommand internal-sftp

# Match user usuario2
# ChrootDirectory /home/sftp/usuario2
# ForceCommand internal-sftp