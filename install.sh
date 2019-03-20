#!/bin/bash
sudo cpan -f Ham::APRS::IS
sudo cpan -f Ham::APRS::FAP 
sudo cpan    DBI
sudo cpan    Data::Dumpe
sudo cpan    Math::Trig 
sudo cpan    FindBin
sudo cpan    Geo::Coordinates::UTM
sudo cpan    JSON
apt-get -y install libapache2-mod-perl2
sudo a2enmod cache
sudo a2enmod cache_disk
sudo adduser ognrange
cd /var/www/html/OGNRANGE
chown -R ognrange:adm .
chmod -R 771 .
chgrp www-data files/* perl/* index.html config/webconfig.json
chmod 771 files perl config
#
# change the URL on index.html & files/maptiles2.js
#
