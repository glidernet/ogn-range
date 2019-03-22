#!/bin/bash
bash deletephantoms.sh NAVITER
bash deletephantoms.sh FLYMASTER
bash deletephantoms.sh SPOT
bash deletephantoms.sh SPIDER
bash deletephantoms.sh INREACH
bash deletephantoms.sh SKYLINES
bash deletephantoms.sh LT24
bash deletephantoms.sh CAPTURS
bash deletephantoms.sh RELAY
bash deleteFNB.sh      FNB
bash deleteFNB.sh      XCG
bash deleteFNB.sh      OGN
mysqlcheck --optimize --skip-write-binlog -u ognwriter -paksdkqre912eqwkadkad ognrange
