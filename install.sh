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
if [ $1 = 'APACHE2' ]
then 
	apt-get -y install libapache2-mod-perl2
	sudo a2enmod cache
	sudo a2enmod cache_disk
	cd /var/www/html/OGNRANGE
else
	cd /var/www/ognrange.glidernet.org/html
fi
echo "Creating user ognrange"
echo "======================"
sudo adduser ognrange
sudo chown -R ognrange:adm .
sudo chmod -R 771 .
sudo chgrp www-data files/* perl/* index.html config/webconfig.json
sudo chmod 775 files perl config
#mysql_config_editor set --login-path=ognrange --host=localhost --user=ognwriter --password
#
# change the URL on: url.js and the webconfig/binconfig files
#
echo Done.
