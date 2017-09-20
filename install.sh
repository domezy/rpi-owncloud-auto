#!/bin/bash
echo "Updating and upgrading packages..."
sudo apt-get update && sudo apt-get -y upgrade
echo "Configuring locales..."
sudo dpkg-reconfigure locales
echo "You can revert locale using raspi-config."
echo "Changing Memory split to 240/16..."
sudo cp /boot/arm240_start.elf /boot/start.elf
echo "Add www-data to www-data group..."
sudo usermod -a -G www-data www-data
echo "Installing packages..."
sudo apt-get install -y \
apache2 mariadb-server libapache2-mod-php7.0 \
    php7.0-gd php7.0-json php7.0-mysql php7.0-curl \
    php7.0-intl php7.0-mcrypt php-imagick \
    php7.0-zip php7.0-xml php7.0-mbstring \
    php7.0-sqlite sqlite3 phpmyadmin \

echo "Install additional Extensions..."
sudo apt-get install -y \
    php-apcu php-redis redis-server \
    php7.0-ldap php-smbclient

while true; do
  echo "Enter your Raspberry Pi's IP address"
  read ipadd
  echo "You have entered $ipadd. Please confirm this is correct? (y/N)"
  read response
  if [ $response = "y" ]; then
    echo "Setting ip as $ipadd."
    break
  else
    echo "Re-enter the correct ip-address. Ctrl-C to exit this loop."
  fi
done

SERVERCONFIG="<VirtualHost *:80>
ServerAdmin webmaster@localhost
DocumentRoot /var/www/owncloud

ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined

<Directory /var/www/owncloud/>
Options +FollowSymlinks
AllowOverride All

<IfModule mod_dav.c>
Dav off
</IfModule>

SetEnv HOME /var/www/owncloud
SetEnv HTTP_HOME /var/www/owncloud

</Directory>
</VirtualHost>"

#sudo touch /etc/apache2/sites-available/default.conf
sudo chmod 666 /etc/apache2/sites-available/000-default.conf
echo "$SERVERCONFIG" > /etc/apache2/sites-available/000-default.conf
sudo chmod 644 /etc/apache2/sites-available000-default.conf

echo "Additional Apache Configurations"
a2enmod rewrite
a2enmod headers
a2enmod env
a2enmod dir
a2enmod mime

echo "Configuring PHP and other stuff..."
sudo sed -i 's/^upload_max_filesize.*$/upload_max_filesize = 2000M/' /etc/php/7.0/apache2/php.ini
sudo sed -i 's/^post_max_size.*$/post_max_size = 2000M/' /etc/php/7.0/apache2/php.ini
#sudo sed -i 's/^listen.*$/listen = 127.0.0.1:9000/' /etc/php7/fpm/pool.d/www.conf
#sudo sed -i 's/^CONF_SWAPSIZE.*$/CONF_SWAPSIZE = 512/' /etc/dphys-swapfile
echo "Done."

echo "Please reboot your raspberry pi and run the owncloud installation script, owncloud.sh. Use 'sudo reboot'"
