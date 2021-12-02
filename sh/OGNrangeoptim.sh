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
sudo mysql  <queryactivestations.sql
echo "Query number of empty stations"
sudo mysql  <queryemptystations.sql
if [ -f /tmp/OGNrangeoptim.pid]
then
      echo "Other OGNRANGE optim process runninng .... "$(cat /tmp/OGNrangeoptim.pid)" if not, delete the /tmp/OGNrangeoptim.pid file"
      exit
fi
#
echo "Stop de OGNRANGE daemon, in order to improve performance"
#
killall perl
# set a mark in order to protect running other process
echo $$ >/tmp/OGNrangeoptim.pid
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
bash deletephantoms.sh NAVITER
bash deletephantoms.sh FLYMASTER
bash deletephantoms.sh SPOT
bash deletephantoms.sh notSPOT
bash deletephantoms.sh SPIDER
bash deletephantoms.sh INREACH
bash deletephantoms.sh Inreach
bash deletephantoms.sh SKYLINES
bash deletephantoms.sh SafeSky
bash deletephantoms.sh LT24
bash deletephantoms.sh CAPTURS
bash deletephantoms.sh RELAY
bash deletephantoms.sh "0"
bash deletephantoms.sh NONE
bash deletephantoms.sh Test
bash deletephantoms.sh N0CALL
bash deletephantoms.sh Home
bash deletephantoms.sh MyStation
bash deletephantoms.sh abcde
bash deletephantoms.sh NEMO
bash deletephantoms.sh Android
bash deletephantoms.sh TTN2OGN
bash deletephantoms.sh TTN3OGN
bash deletephantoms.sh Heliu2OGN
bash deletephantoms.sh OBS2OGN
bash deletephantoms.sh APRSPUSH
bash deletephantoms.sh DLY2APRS
bash deletephantoms.sh IGCDroid
bash deletephantoms.sh Microtrack
bash deletephantoms.sh GIGA01
bash deletephantoms.sh UNSET
bash deletephantoms.sh PWUNSET
bash deletephantoms.sh GLIDERNA
###################################

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
bash deleteFNB.sh      SKYS     Y
bash deleteFNB.sh      ADSB     Y
#
echo "deleting the data before January 2018"
#
#mysql  ognrange <config/deleteoldata.sql
#
date
echo "Delete empty stations"
mysql -e "delete from stations where otime = '1970-01-01';" ognrange
sudo mysql  <delemptystations.sql
date
echo "Check and delete stations with no location and data with no station in the ognrange database"
#
date
python delzombies.py
date
#bash deloldstations.sh
#date
echo "Delete record with station that do not exist anymore on the database"
bash delzombies.sh
date
#
echo "Check the ognrange database"
#
date
sudo mysql         -e "reset query cache;"           ognrange
sudo mysqlcheck                                      ognrange
sudo mysql         -e "reset query cache;"           ognrange
date
echo "Optimize the ognrange database"
sudo mysqlcheck    --optimize --skip-write-binlog    ognrange
#
echo "Count now the number of zombie stations"
#
date
bash countoldstations.sh
date
bash countzombies.sh
date
echo "Query number of active stations"
sudo mysql  <queryactivestations.sql
echo "Query number of empty stations"
mysql  <queryemptystations.sql
#
echo "Start de OGNRANGE daemon ..."
#
# remove the mark that this process is running
rm /tmp/OGNrangeoptim
date
} | mutt  -s $hn" REPOOGN OGNRANGE DB cleanup .... "$taken -- yourname@yourserver.es
bash ~/src/OGNrangecheck.sh  &
cd
