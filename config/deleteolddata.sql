use ognrange;
set innodb_lock_wait_timeout=100;
SELECT 'availlog:', count(*) FROM `availability_log` WHERE time < unix_timestamp('2019-01-01');
DELETE FROM `availability_log` WHERE time < unix_timestamp('2019-01-01');
optimize table availability_log;
SELECT 'History:', count(*) FROM `history` WHERE time <'2019-01-01';
DELETE FROM `history` WHERE time <'2019-01-01';
optimize table history;
SELECT 'Stats:', count(*) FROM `stats` WHERE time <'2019-01-01';
DELETE FROM `stats` WHERE time <'2019-01-01';
optimize table stats;
SELECT 'PosMgrs:', count(*) FROM `positions_mgrs` WHERE `time` < '2019-01-01';
DELETE FROM `positions_mgrs` WHERE `time` < '2019-01-01';
optimize table positions_mgrs;


