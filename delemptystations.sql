use ognrange;
set time_zone = "+00:00";
set session sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
delete from stations where otime = '1970-01-01' and active = 'N' and id not in (select distinct station  from positions_mgrs);
