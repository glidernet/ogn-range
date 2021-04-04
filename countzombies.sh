#!/bin/bash
sudo mysql  -e 'select "Station Location: ", count(*)  FROM stationlocation  WHERE station    not in (select id from stations)'  ognrange
sudo mysql  -e 'select "Position Mgrs:    ", count(*)  FROM positions_mgrs   WHERE station    not in (select id from stations)'  ognrange
sudo mysql  -e 'select "Availability:     ", count(*)  FROM availability     WHERE station_id not in (select id from stations) ' ognrange
sudo mysql  -e 'select "Availability log: ", count(*)  FROM availability_log WHERE station_id not in (select id from stations) ' ognrange
sudo mysql  -e 'select "Rough Coverage:   ", count(*)  FROM roughcoverage    WHERE station    not in (select id from stations) ' ognrange
sudo mysql  -e 'select "Estimated Coverage:   ", count(*)  FROM estimatedcoverage    WHERE station    not in (select id from stations) ' ognrange
sudo mysql  -e 'select "Stats:            ", count(*)  FROM stats            WHERE station    not in (select id from stations) ' ognrange
sudo mysql  -e 'select "Stats Summary:    ", count(*)  FROM statssummary     WHERE station    not in (select id from stations) ' ognrange


