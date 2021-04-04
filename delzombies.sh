#!/bin/bash
echo "Delete data related to zombie stations that are not active anymore"
sudo mysql  -e 'delete  FROM stationlocation  WHERE station    not in (select id from stations)'  ognrange
#sudo mysql  -e 'delete  FROM positions_mgrs   WHERE station    not in (select id from stations)'  ognrange
sudo mysql  -e 'delete  FROM availability     WHERE station_id not in (select id from stations) ' ognrange
sudo mysql  -e 'delete  FROM availability_log WHERE station_id not in (select id from stations) ' ognrange
sudo mysql  -e 'delete  FROM roughcoverage    WHERE station    not in (select id from stations) ' ognrange
sudo mysql  -e 'delete  FROM estimatedcoverage WHERE station    not in (select id from stations) ' ognrange
sudo mysql  -e 'delete  FROM stats            WHERE station    not in (select id from stations) ' ognrange
sudo mysql  -e 'delete  FROM statssummary     WHERE station    not in (select id from stations) ' ognrange


