#!/bin/bash
mysql --login-path=ognrange -e 'delete  FROM stationlocation  WHERE station    not in (select id from stations)'  ognrange
mysql --login-path=ognrange -e 'delete  FROM positions_mgrs   WHERE station    not in (select id from stations)'  ognrange
mysql --login-path=ognrange -e 'delete  FROM availability     WHERE station_id not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'delete  FROM availability_log WHERE station_id not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'delete  FROM roughcoverage    WHERE station    not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'delete  FROM stats            WHERE station    not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'delete  FROM statssummary     WHERE station    not in (select id from stations) ' ognrange


