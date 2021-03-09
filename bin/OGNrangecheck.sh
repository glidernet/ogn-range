#!/bin/bash
alive="/nfs/OGN/DIRdata/OGNRANGE.alive"
if [ ! -f $alive ]	# if the file is not there
then
	logger  -t $0 "OGNRANGE is not alive"
	pnum=$(pgrep -x -f "perl fetchrange3.pl")
	if [ $? -eq 0 ] # if OGNRANGE interface is running
	then
    		kill $pnum
    	        logger -t $0 "Killing job: "$pnum
	fi
	#       restart OGNRANGE data collector
    	logger -t $0 "OGNrange Log seems down, restarting"
    	date >>/nfs/OGN/DIRdata/log/.OGNrangerestart.log
        touch $alive 
    	bash ~/src/OGNrange.sh &
else
        logger -t $0 "OGNRANGE is alive"
	rm $alive   # so we can check it next time around
fi


