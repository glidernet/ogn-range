#!/bin/bash
cd /var/www/html/OGNRANGE/bin
echo $(date +%H:%M:%S)                                     >/tmp/OGNrange$(date +%y%m%d-%H-%M-%S).log
echo $(date +%H:%M:%S)                                     >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d-%H).log
echo "============="                                       >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d-%H).log
perl 				fetchrange3.pl             >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d-%H).log  2>&1
rm  /tmp/OGNrange*
echo "============="                                       >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d-%H).log
cd
