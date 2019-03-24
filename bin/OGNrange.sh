#!/bin/bash
cd /var/www/html/OGNRANGE/bin
echo $(date +%H:%M:%S)                                     >/tmp/OGNrange$(date +%y%m%d-%H-%M-%S).log
echo $(date +%H:%M:%S)                                     >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d-%H).log
echo "============="                                       >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d-%H).log
perl 				fetchrange3.pl >/dev/null 2>>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d-%H).log &
echo "============="                                       >>/nfs/OGN/DIRdata/log/OGNrange$(date +%y%m%d-%H).log
cd
