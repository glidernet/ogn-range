#!/bin/bash
echo "Delete data where we have not data on the station location"
ps=$(mysql  -e 'select count(*)                                                                  from stationlocation where lt is NULL ' ognrange)
nc=$(echo $ps | sed 's/^count(\*) //g')
if [ $nc != '0' ]
then 
   mysql  -e 'DELETE FROM positions_mgrs   WHERE station in    (select distinct station from stationlocation where lt is NULL) ' ognrange
fi
mysql  -e 'DELETE FROM availability     WHERE station_id in (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'DELETE FROM availability_log WHERE station_id in (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'DELETE FROM roughcoverage    WHERE station in    (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'DELETE FROM estimatedcoverage WHERE station in    (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'DELETE FROM stats            WHERE station in    (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'DELETE FROM statssummary     WHERE station in    (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'DELETE FROM stations         WHERE id      in    (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'DELETE                                                                    from stationlocation where lt is NULL ' ognrange


