#!/bin/bash
#
echo "Deleteing the phantom STATIOS"
#
bash deletephantoms.sh NAVITER
bash deletephantoms.sh FLYMASTER
bash deletephantoms.sh SPOT
bash deletephantoms.sh SPIDER
bash deletephantoms.sh INREACH
bash deletephantoms.sh SKYLINES
bash deletephantoms.sh LT24
bash deletephantoms.sh CAPTURS
bash deletephantoms.sh RELAY
bash deletephantoms.sh 0
bash deletephantoms.sh Test
bash deletephantoms.sh N0CALL
bash deletephantoms.sh Home
bash deletephantoms.sh MyStation
bash deletephantoms.sh abcde
#
echo "deleting the pseudo STATIONS"
#
bash deleteFNB.sh      FNB
bash deleteFNB.sh      XCG
bash deleteFNB.sh      XCC
bash deleteFNB.sh      OGN
bash deleteFNB.sh      ICA
bash deleteFNB.sh      FLR
bash deleteFNB.sh      bSkyN
bash deleteFNB.sh      AIRS
bash deleteFNB.sh      AIRS-
bash deleteFNB.sh      TEST
#
echo "deleting the data before January 2018"
#
mysql --login-path=ognrange ognrange <config/deleteoldata.sql
#
echo "Check and optimize the ognrange database"
#
mysql        -e "reset query cache;"           --login-path=ognrange ognrange
mysqlcheck                                     --login-path=ognrange ognrange
mysql        -e "reset query cache;"           --login-path=ognrange ognrange
mysqlcheck --optimize --skip-write-binlog      --login-path=ognrange ognrange
