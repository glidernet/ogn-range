#!/bin/bash
sudo cpan -f Ham::APRS::IS
sudo cpan -f Ham::APRS::FAP 
sudo cpan    DBI
sudo cpan    Data::Dumpe
sudo cpan    Math::Trig 
sudo cpan    FindBin
sudo cpan    Geo::Coordinates::UTM
sudo cpan    DateTime
sudo cpan    sys::Hostname::Long
sudo cpan    JSON
apt-get -y install libapache2-mod-perl2
sudo a2enmod cache
sudo a2enmod cache_disk
sudo adduser ognrange
cd /var/www/html/OGNRANGE
sudo chown -R ognrange:adm .
sudo chmod -R 771 .
sudo chgrp www-data files/* perl/* index.html config/webconfig.json
sudo chmod 775 files perl config
mysql_config_editor set --login-path=ognrange --host=localhost --user=ognwriter --password
#
# change the URL on: url.js and the webconfig/binconfig files
#
echo Done.
