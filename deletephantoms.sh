#!/bin/bash
echo "select * from stations                where  station = '$1';"       
echo "select * from stations                where  station = '$1';"                                                | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from stationlocation         where  station     = (select id from stations where station = '$1'); " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from roughcoverage           where  station     = (select id from stations where station = '$1'); " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from availability            where  station_id  = (select id from stations where station = '$1'); " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from availability_log        where  station_id  = (select id from stations where station = '$1'); " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from positions_mgrs          where  station     = (select id from stations where station = '$1'); " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from stats                   where  station     = (select id from stations where station = '$1'); " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from statssummary            where  station     = (select id from stations where station = '$1'); " | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
echo "delete   from stations                where  station = '$1'; "                                               | mysql ognrange  -u ognwriter -paksdkqre912eqwkadkad 2>/dev/null
