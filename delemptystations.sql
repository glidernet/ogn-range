delete from stations where otime = '1970-01-01' and active = 'N' and id not in (select distinct station  from positions_mgrs);
