
SELECT count(*) FROM `availability_log` WHERE time < unix_timestamp('2018-01-01');
DELETE FROM `availability_log` WHERE time < unix_timestamp('2018-01-01');
SELECT count(*) FROM `positions_mgrs` WHERE `time` < '2018-01-01';
DELETE FROM `positions_mgrs` WHERE `time` < '2018-01-01';
SELECT count(*) FROM `history` WHERE time <'2018-01-01';
DELETE FROM `history` WHERE time <'2018-01-01';
