#!/bin/bash
mysql  -e 'select "Station Location ", count(*)                                                            from stationlocation where lt is NULL ' ognrange
mysql  -e 'select "Position mgrs    ", count(*)  FROM positions_mgrs   WHERE station in    (select station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'select "Availability     ", count(*)  FROM availability     WHERE station_id in (select station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'select "Availability Log ", count(*)  FROM availability_log WHERE station_id in (select station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'select "Rought coverage  ", count(*)  FROM roughcoverage    WHERE station in    (select station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'select "Estimated coverage  ", count(*)  FROM estimatedcoverage    WHERE station in    (select station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'select "Stats            ", count(*)  FROM stats            WHERE station in    (select station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'select "Stats Summary    ", count(*)  FROM statssummary     WHERE station in    (select station from stationlocation where lt is NULL) ' ognrange
mysql  -e 'select "Stations         ", count(*)  FROM stations         WHERE id      in    (select station from stationlocation where lt is NULL) ' ognrange


