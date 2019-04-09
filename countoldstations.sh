#!/bin/bash
mysql --login-path=ognrange -e 'select "stl", count(*)                                                            from stationlocation where lt is NULL ' ognrange
mysql --login-path=ognrange -e 'select "pos", count(*)  FROM positions_mgrs   WHERE station in    (select station from stationlocation where lt is NULL) ' ognrange
mysql --login-path=ognrange -e 'select "ava", count(*)  FROM availability     WHERE station_id in (select station from stationlocation where lt is NULL) ' ognrange
mysql --login-path=ognrange -e 'select "avl", count(*)  FROM availability_log WHERE station_id in (select station from stationlocation where lt is NULL) ' ognrange
mysql --login-path=ognrange -e 'select "rou", count(*)  FROM roughcoverage    WHERE station in    (select station from stationlocation where lt is NULL) ' ognrange
mysql --login-path=ognrange -e 'select "sts", count(*)  FROM stats            WHERE station in    (select station from stationlocation where lt is NULL) ' ognrange
mysql --login-path=ognrange -e 'select "sss", count(*)  FROM statssummary     WHERE station in    (select station from stationlocation where lt is NULL) ' ognrange
mysql --login-path=ognrange -e 'select "sta", count(*)  FROM stations         WHERE id      in    (select station from stationlocation where lt is NULL) ' ognrange


