
Copyright (c) 2014-2018, Melissa Jenkins
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * The names of its contributors may not be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL MELISSA JENKINS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



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



#
# Finally, the bin/fetchrange3.pl script will connect to the APRS servers and update the database
# it should be run as a daemon using the user created above
#
