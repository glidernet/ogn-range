#!/bin/bash
if [ -f /tmp/OGNrangeoptim.pid ]
then
    logger -t $0 "OGNrange optimization in progress ..."
    exit
fi
pnum=$(pgrep -x -f "perl fetchrange3.pl")
if [ $? -eq 0 ] # if OGN repo interface is  not running
then
    logger -t $0 "OGNrange Log is alive"
else
	#               restart OGN data collector
    logger -t $0 "OGNrange Log seems down, restarting"
    date >>/nfs/OGN/DIRdata/log/.OGNrangerestart.log
    bash ~/src/sh/OGNrange.sh &
fi

