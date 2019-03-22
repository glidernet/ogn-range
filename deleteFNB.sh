#!/bin/bash
echo "select * from stations                where                                                station > '$1000000' and station < '$1999999'; "       
echo "select * from stations                where                                                station > '$1000000' and station < '$1999999'; " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from stationlocation         where  station     IN (select id from stations where station > '$1000000' and station < '$1999999'; " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from roughcoverage           where  station     IN (select id from stations where station > '$1000000' and station < '$1999999'; " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from availability            where  station_id  IN (select id from stations where station > '$1000000' and station < '$1999999'; " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from availability_log        where  station_id  IN (select id from stations where station > '$1000000' and station < '$1999999'; " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from positions_mgrs          where  station     IN (select id from stations where station > '$1000000' and station < '$1999999'; " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from stats                   where  station     IN (select id from stations where station > '$1000000' and station < '$1999999'; " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from statssummary            where  station     IN (select id from stations where station > '$1000000' and station < '$1999999'; " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from stations                where                                                station > '$1000000' and station < '$1999999'; " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
# DELETE FROM `stationlocation` WHERE station IN (SELECT id FROM `stations` WHERE `station` > 'FNB000000' and `station` < 'FNB999999')
