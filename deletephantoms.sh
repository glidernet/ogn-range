#!/bin/bash
echo "Delete invalid station: "$1
echo "select count(*) from stations              where  station = '$1';"       
mysql  -e "select count(*) from stations         where  station = '$1';"                                                ognrange
mysql  -e "delete   from stationlocation         where  station     = (select id from stations where station = '$1'); " ognrange 
mysql  -e "delete   from roughcoverage           where  station     = (select id from stations where station = '$1'); " ognrange
mysql  -e "delete   from estimatedcoverage       where  station     = (select id from stations where station = '$1'); " ognrange
mysql  -e "delete   from availability            where  station_id  = (select id from stations where station = '$1'); " ognrange
mysql  -e "delete   from availability_log        where  station_id  = (select id from stations where station = '$1'); " ognrange
mysql  -e "delete   from positions_mgrs          where  station     = (select id from stations where station = '$1'); " ognrange
mysql  -e "delete   from stats                   where  station     = (select id from stations where station = '$1'); " ognrange
mysql  -e "delete   from statssummary            where  station     = (select id from stations where station = '$1'); " ognrange
mysql  -e "delete   from stations                where  station = '$1'; "                                               ognrange
