#!/bin/bash
mysql --login-path=ognrange -e 'select "Station Location: ", count(*)  FROM stationlocation  WHERE station    not in (select id from stations)'  ognrange
mysql --login-path=ognrange -e 'select "Position Mgrs:    ", count(*)  FROM positions_mgrs   WHERE station    not in (select id from stations)'  ognrange
mysql --login-path=ognrange -e 'select "Availability:     ", count(*)  FROM availability     WHERE station_id not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'select "Availability log: ", count(*)  FROM availability_log WHERE station_id not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'select "Rough Coverage:   ", count(*)  FROM roughcoverage    WHERE station    not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'select "Estimated Coverage:   ", count(*)  FROM estimatedcoverage    WHERE station    not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'select "Stats:            ", count(*)  FROM stats            WHERE station    not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'select "Stats Summary:    ", count(*)  FROM statssummary     WHERE station    not in (select id from stations) ' ognrange


