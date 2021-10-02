#!/bin/bash
cd /var/www/html/OGNRANGE
day=`date "+%a"`
DMY=`date "+%x"`
now=`date "+%R"`
hn=`hostname   `
taken=$day"_"$DMY"_"$now

{
echo "Starting deleting zombie stations at: "$(date)
date
echo "Query number of active stations"
mysql --login-path=ognrange <queryactivestations.sql
echo "Query number of empty stations"
mysql --login-path=ognrange <queryemptystations.sql
#
echo "Stop de OGNRANGE daemon, in order to improve performance"
#
killall perl
#
echo "Count first the number of zombie stations"
#
bash countoldstations.sh
bash countzombies.sh
#
echo "Deleting the phantom STATIONS"
#
date
bash deletephantoms.sh NAVITER
bash deletephantoms.sh FLYMASTER
bash deletephantoms.sh SPOT
bash deletephantoms.sh SPIDER
bash deletephantoms.sh INREACH
bash deletephantoms.sh SKYLINES
bash deletephantoms.sh SkySafe
bash deletephantoms.sh LT24
bash deletephantoms.sh CAPTURS
bash deletephantoms.sh RELAY
bash deletephantoms.sh "0"
bash deletephantoms.sh Test
bash deletephantoms.sh N0CALL
bash deletephantoms.sh Home
bash deletephantoms.sh MyStation
bash deletephantoms.sh abcde
#
echo "Deleting the pseudo STATIONS"
#
date
bash deleteFNB.sh      FNB      Y
bash deleteFNB.sh      XCG      Y
bash deleteFNB.sh      XCC      Y
bash deleteFNB.sh      OGN      Y
bash deleteFNB.sh      ICA      Y
bash deleteFNB.sh      FLR      Y
bash deleteFNB.sh      SKY      Y
bash deleteFNB.sh      bSkyN    Y
bash deleteFNB.sh      AIRS     Y
bash deleteFNB.sh      AIRS-    Y
bash deleteFNB.sh      TEST     Y
#
echo "deleting the data before January 2018"
#
#mysql --login-path=ognrange ognrange <config/deleteoldata.sql
#
date
echo "Delete empty stations"
mysql --login-path=ognrange <delemptystations.sql
date
echo "Check and delete stations with no location and data with no station in the ognrange database"
#
date
python3 delzombies.py
date
bash deloldstations.sh
date
echo "Delete record with station that do not exist anymore on the database"
bash delzombies.sh
date
#
echo "Check the ognrange database"
#
date
mysql        --login-path=ognrange -e "reset query cache;"           ognrange
mysqlcheck   --login-path=ognrange                                   ognrange
mysql        --login-path=ognrange -e "reset query cache;"           ognrange
date
echo "Optimize the ognrange database"
mysqlcheck   --login-path=ognrange --optimize --skip-write-binlog    ognrange
#
echo "Count now the number of zombie stations"
#
date
bash countoldstations.sh
date
bash countzombies.sh
date
echo "Query number of active stations"
mysql --login-path=ognrange <queryactivestations.sql
echo "Query number of empty stations"
mysql --login-path=ognrange <queryemptystations.sql
#
echo "Start de OGNRANGE daemon ..."
#
date
} | mutt  -s $hn" REPOOGN OGNRANGE DB cleanup .... "$taken -- angel@acasado.es
bash ~/src/sh/OGNrangecheck.sh  &
cd
