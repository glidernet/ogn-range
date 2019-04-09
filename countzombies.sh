#!/bin/bash
mysql --login-path=ognrange -e 'select "stl", count(*)  FROM stationlocation  WHERE station    not in (select id from stations)'  ognrange
mysql --login-path=ognrange -e 'select "pos", count(*)  FROM positions_mgrs   WHERE station    not in (select id from stations)'  ognrange
mysql --login-path=ognrange -e 'select "ava", count(*)  FROM availability     WHERE station_id not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'select "avl", count(*)  FROM availability_log WHERE station_id not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'select "rou", count(*)  FROM roughcoverage    WHERE station    not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'select "sts", count(*)  FROM stats            WHERE station    not in (select id from stations) ' ognrange
mysql --login-path=ognrange -e 'select "sss", count(*)  FROM statssummary     WHERE station    not in (select id from stations) ' ognrange


