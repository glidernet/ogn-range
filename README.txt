
#
# These scripts all run using Apache Mod Perl 2, using registry mode.  The database used has been mysql 5.6 with the perl DBI driver
# You will need to install apache24, mod_perl2,
# the following perl modules are also needed

 use Ham::APRS::IS;
 use Ham::APRS::FAP qw(parseaprs);
 use DBI;
 use Data::Dumper;
 use Math::Trig qw(:great_circle deg2rad rad2deg);
 use FindBin;
 use Geo::Coordinates::UTM;
 use JSON;

#
# use the following to fix file permissions
# you should NOT use the web server username for the directory, ideally create a new user and make sure all the files are owned by that!
# (eg ognrange).  End result is that webserver can read files from the files & perl directory as well as index but nothing else
# it also can't list directories - this may be a pain when developing new filters as you need to remember to change group to www for each new file ;)

 chown -R ognrange:ognrange .
 chmod -R 750 .
 chgrp www files/* perl/* index.html config/webconfig.json
 chmod 751 files perl config
 

# First load the database schema then you need to create the database users and then allow them access
# to the database.  Use different users and passwords for read than for write and CHANGE THE ONES BELOW!
# You also need to rename and edit the two .json files to configure them for your database settings

 create database ognrange;
 use ognrange;
 source <directory>/config/schema.sql

 create user ognrange@localhost identified by 'aksdkqre912eqwkadkad';
 grant select on ognrange.* to ognrange@localhost

 create user ognwriter@localhost identified by 'aksdkqre912eqwkadkad';
 grant select, update, insert, create temporary tables, drop on ognrange.* to ognwriter@localhost

 flush privileges;


