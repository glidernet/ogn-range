#!/bin/bash
cd /var/www/html/OGNRANGE/bin
echo $$                                                     >/tmp/OGNrange$(date +%y%m%d-%H-%M-%S).log
echo $(date +%H:%M:%S)                                     >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d).log
echo "============="                                       >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d).log
perl 				fetchrange3.pl             >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d).log  2>&1
rm  /tmp/OGNrange*
echo "============="                                       >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d).log
cd
