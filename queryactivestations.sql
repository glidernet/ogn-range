use ognrange;
set time_zone = "+00:00";
set session sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
select "Active stations time: ", count(*) from stations where otime + 600 > now();
select "Active stations stat: ", count(*) from stations where active = 'Y';
select "Total  stations     : ", count(*) from stations;
