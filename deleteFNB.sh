#!/bin/bash
echo                           "select * from stations                where                                                station like '$1%' and active = '$2'; "       
mysql --login-path=ognrange -e "select * from stations                where                                                station like '$1%' and active = '$2'; " ognrange
mysql --login-path=ognrange -e "delete   from stationlocation         where  station     IN (select id from stations where station like '$1%' and active = '$2');" ognrange
mysql --login-path=ognrange -e "delete   from roughcoverage           where  station     IN (select id from stations where station like '$1%' and active = '$2');" ognrange
mysql --login-path=ognrange -e "delete   from availability            where  station_id  IN (select id from stations where station like '$1%' and active = '$2');" ognrange
mysql --login-path=ognrange -e "delete   from availability_log        where  station_id  IN (select id from stations where station like '$1%' and active = '$2');" ognrange
mysql --login-path=ognrange -e "delete   from positions_mgrs          where  station     IN (select id from stations where station like '$1%' and active = '$2');" ognrange
mysql --login-path=ognrange -e "delete   from stats                   where  station     IN (select id from stations where station like '$1%' and active = '$2');" ognrange
mysql --login-path=ognrange -e "delete   from statssummary            where  station     IN (select id from stations where station like '$1%' and active = '$2');" ognrange
mysql --login-path=ognrange -e "delete   from stations                where                                                station like '$1%' and active = '$2' ;" ognrange
