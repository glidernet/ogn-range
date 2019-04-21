#!/bin/bash
echo "Delete data where we have not data on the station location"
mysql --login-path=ognrange -e 'select *                                                                  from stationlocation where lt is NULL ' ognrange
#mysql --login-path=ognrange -e 'DELETE FROM positions_mgrs   WHERE station in    (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql --login-path=ognrange -e 'DELETE FROM availability     WHERE station_id in (select distinct station from stationlocation where lt is NULL) ' ognrange
#mysql --login-path=ognrange -e 'DELETE FROM availability_log WHERE station_id in (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql --login-path=ognrange -e 'DELETE FROM roughcoverage    WHERE station in    (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql --login-path=ognrange -e 'DELETE FROM estimatedcoverage WHERE station in    (select distinct station from stationlocation where lt is NULL) ' ognrange
#mysql --login-path=ognrange -e 'DELETE FROM stats            WHERE station in    (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql --login-path=ognrange -e 'DELETE FROM statssummary     WHERE station in    (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql --login-path=ognrange -e 'DELETE FROM stations         WHERE id      in    (select distinct station from stationlocation where lt is NULL) ' ognrange
mysql --login-path=ognrange -e 'DELETE                                                                    from stationlocation where lt is NULL ' ognrange


