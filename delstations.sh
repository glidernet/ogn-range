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
mysql -u ognwriter -paksdkqre912eqwkadkad ognrange <config/deleteoldata.sql
#
echo "Check and optimize the ognrange database"
#
mysql        -e "reset query cache;"           -u ognwriter -paksdkqre912eqwkadkad ognrange
mysqlcheck                                     -u ognwriter -paksdkqre912eqwkadkad ognrange
mysql        -e "reset query cache;"           -u ognwriter -paksdkqre912eqwkadkad ognrange
mysqlcheck --optimize --skip-write-binlog      -u ognwriter -paksdkqre912eqwkadkad ognrange
