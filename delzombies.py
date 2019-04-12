from ctypes import *
from datetime import datetime
import time
import string
import sys
import os
import os.path
import atexit
import json
import signal
import socket
import MySQLdb                  # thdde SQL data base routines^M
print "Start OGNRANGE delete zombies "
print "=============================="

date=datetime.utcnow()                  # get the date
dte=date.strftime ("%y%m%d %H:%M:%S")             # today's date
DBhost                  = "localhost"
DBname                  = "ognrange"
with open('config/binconfig.json', 'r') as f:
    cnfg = json.load(f)
config=cnfg['config']
print "Config:", cnfg, config
DBuser                  = config['dbusername']
DBpasswd                = config['dbpassword']
dlt=True
conn=MySQLdb.connect(host=DBhost, user=DBuser, passwd=DBpasswd, db=DBname)
print "MySQL Database:", DBname, " at Host:", DBhost
print "Start Date:", dte
curs1=conn.cursor()
curs2=conn.cursor()
row=""
row2=""
cnt1=0
cnt2=0
selcmd1="select distinct station from positions_mgrs where station not in (select id from stations)"
selcmd2="select distinct station from stationlocation where lt is NULL"
selcmd3="select distinct station from stats where station not in (select id from stations)"
try:
    curs1.execute(selcmd1)
    row = curs1.fetchone()
except MySQLdb.Error, e:
    try:
        print ">>>MySQL Error [%d]: %s" % (e.args[0], e.args[1])
    except IndexError:
        print ">>>MySQL Error: %s" % str(e)
        print ">>>MySQL error:", selcmd
print "R1", row
while row is not None:
    cnt1 +=1 
    try:
        if (dlt):
            delcmd1="delete from positions_mgrs   where station = "+str(row[0])
            curs2.execute(delcmd1)
        else:    
            curs2.execute( "select * from positions_mgrs where station = "+str(row[0]))
            for row2 in curs2:
                #print "R2:", (row2)
                cnt2 +=1 
    except MySQLdb.Error, e:
     try:
        print ">>>MySQL Error [%d]: %s" % (e.args[0], e.args[1])
     except IndexError:
        print ">>>MySQL Error: %s" % str(e)
        print ">>>MySQL error:", delcmd
    conn.commit()
    row = curs1.fetchone()
    print "R1", row

print "Pos mngrs:", cnt1, cnt2
cnt1=0
cnt2=0
try:
    curs1.execute(selcmd2)
    row = curs1.fetchone()
except MySQLdb.Error, e:
    try:
        print ">>>MySQL Error [%d]: %s" % (e.args[0], e.args[1])
    except IndexError:
        print ">>>MySQL Error: %s" % str(e)
        print ">>>MySQL error:", selcmd
print "R1", row
while row is not None:
    cnt1 +=1 
    try:
        if (dlt):
            delcmd2="DELETE FROM availability_log WHERE station_id = "+str(row[0])
            curs2.execute(delcmd2)
        else:    
            curs2.execute( "select * FROM availability_log WHERE station_id = "+str(row[0]))
            for row2 in curs2:
                #print "R2:", (row2)
                cnt2 +=1 
    except MySQLdb.Error, e:
     try:
        print ">>>MySQL Error [%d]: %s" % (e.args[0], e.args[1])
     except IndexError:
        print ">>>MySQL Error: %s" % str(e)
        print ">>>MySQL error:", delcmd
    conn.commit()
    row = curs1.fetchone()
    print "R1", row

print "avail log:", cnt1, cnt2
cnt1=0
cnt2=0
try:
    curs1.execute(selcmd3)
    row = curs1.fetchone()
except MySQLdb.Error, e:
    try:
        print ">>>MySQL Error [%d]: %s" % (e.args[0], e.args[1])
    except IndexError:
        print ">>>MySQL Error: %s" % str(e)
        print ">>>MySQL error:", selcmd
print "R1", row
while row is not None:
    cnt1 +=1 
    try:
        if (dlt):
            delcmd3="DELETE FROM stats WHERE station = "+str(row[0])
            curs2.execute(delcmd2)
        else:    
            curs2.execute( "select * FROM stats WHERE station = "+str(row[0]))
            for row2 in curs2:
                #print "R2:", (row2)
                cnt2 +=1 
    except MySQLdb.Error, e:
     try:
        print ">>>MySQL Error [%d]: %s" % (e.args[0], e.args[1])
     except IndexError:
        print ">>>MySQL Error: %s" % str(e)
        print ">>>MySQL error:", delcmd
    conn.commit()
    row = curs1.fetchone()
    print "R1", row

print "Stats:", cnt1, cnt2
date=datetime.utcnow()                  # get the date
dte=date.strftime ("%y%m%d %H:%M:%S")             # today's date
conn.commit()
print "End Date:", dte
