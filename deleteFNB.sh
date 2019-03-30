#!/bin/bash
echo "select * from stations                where                                                station > '$1000000' and station < '$1FFFFFF' and active = '$2'; "       
echo "select * from stations                where                                                station > '$1000000' and station < '$1FFFFFF' and active = '$2'; " | mysql ognrange  --login-path=ognrange 2>/dev/null
echo "delete   from stationlocation         where  station     IN (select id from stations where station > '$1000000' and station < '$1FFFFFF' and active = '$2'; " | mysql ognrange  --login-path=ognrange 2>/dev/null
echo "delete   from roughcoverage           where  station     IN (select id from stations where station > '$1000000' and station < '$1FFFFFF' and active = '$2'; " | mysql ognrange  --login-path=ognrange 2>/dev/null
echo "delete   from availability            where  station_id  IN (select id from stations where station > '$1000000' and station < '$1FFFFFF' and active = '$2'; " | mysql ognrange  --login-path=ognrange 2>/dev/null
echo "delete   from availability_log        where  station_id  IN (select id from stations where station > '$1000000' and station < '$1FFFFFF' and active = '$2'; " | mysql ognrange  --login-path=ognrange 2>/dev/null
echo "delete   from positions_mgrs          where  station     IN (select id from stations where station > '$1000000' and station < '$1FFFFFF' and active = '$2'; " | mysql ognrange  --login-path=ognrange 2>/dev/null
echo "delete   from stats                   where  station     IN (select id from stations where station > '$1000000' and station < '$1FFFFFF' and active = '$2'; " | mysql ognrange  --login-path=ognrange 2>/dev/null
echo "delete   from statssummary            where  station     IN (select id from stations where station > '$1000000' and station < '$1FFFFFF' and active = '$2'; " | mysql ognrange  --login-path=ognrange 2>/dev/null
echo "delete   from stations                where                                                station > '$1000000' and station < '$1FFFFFF' and active = '$2'; " | mysql ognrange  --login-path=ognrange 2>/dev/null
