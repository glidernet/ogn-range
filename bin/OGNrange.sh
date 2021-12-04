#!/bin/bash
cd /var/www/html/OGNRANGE/bin
mysql -e "delete from stations where otime = '1970-01-01';" ognrange
mysql -e "delete from stats where station = 0 ;"            ognrange
echo $$                                                     >/tmp/OGNrange$(date +%y%m%d-%H-%M-%S).log
echo $(date +%H:%M:%S)                                     >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d).log
echo "============="                                       >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d).log
perl 	fetchrange3.pl $(date)			           >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d).log  2>&1
rm  /tmp/OGNrange*
echo "============="                                       >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d).log
cd
