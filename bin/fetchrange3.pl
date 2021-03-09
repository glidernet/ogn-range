#!/usr/bin/perl -w                                                                                                                                                      

# Copyright (c) 2014-2018, Melissa Jenkins
# Modified by Angel Casado -2018-???
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * The names of its contributors may not be used to endorse or promote products
#       derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL MELISSA JENKINS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 

use strict;
use threads;
use threads::shared;
use Thread::Semaphore;
use Storable;
use Carp 'verbose';
use Ham::APRS::IS;
use Ham::APRS::FAP qw(parseaprs);
use DBI;
use Data::Dumper;
use Math::Trig qw(:great_circle deg2rad rad2deg);
use FindBin;
use lib $FindBin::Bin;
use Geo::Coordinates::UTM;
use DateTime;
use Socket qw(SOL_SOCKET SO_RCVBUF);
use IO::Socket::INET;
use JSON;
use Config;
use Fcntl ':flock';
# --------------------- #
my $id = 'GLDDBF61';
my %countries :shared;


use LatLngCoarse2;
#
## set prt =1 if you want printing debugging information
#

my $prt=0;
my $pgmversion = "0.4.2";

#
# load the configuration file
#
my $filename = "../config/binconfig.json";

my $json_text = do {
    open(my $json_fh, "<:encoding(UTF-8)", $filename)
	or die("Can't open \"$filename\": $!\n");
    local $/;
    <$json_fh>
};

use Sys::Hostname;
my $host = hostname();
my $ppid = getppid();
use Sys::Hostname::Long 'hostname_long';
my $hostname = hostname_long();
use Socket;
my $address = inet_ntoa(
        	scalar gethostbyname( $host || 'localhost' )
    );
warn "\nOGN Range analyzer Version: $pgmversion \n";
warn "Host === $host === \n";
warn "Host === $hostname === \n";
warn "IP addr === $address === \n";
warn "ProcessID: $ppid  \n";
warn "OSname: $Config{osname}\n";
warn "OSname: $Config{archname}\n";
my $datestring = localtime();
print     "--------------  Local date and time $datestring --------\n";
# assure that not a copy of this program is running
open my $self, '<', $0         or die "Couldn't open self: $!";
flock $self, LOCK_EX | LOCK_NB or die "This script OGNRANGE is already running";
#warn "ProcessID $PID\n";
#
#Get the credential from the config file
#
my $json = JSON->new;
my $data = $json->decode($json_text);

my $db_dsn      = $data->{config}->{dsn} || die "no dsn specified";
my $db_username = $data->{config}->{dbusername} || die "no user specified";
my $db_password = $data->{config}->{dbpassword} || die "no user specified";


#
##########
#
# Configuration
#
##########
#
my @servers = ( 'glidern1.glidernet.org:10153', 
		'glidern2.glidernet.org:10153', 
		'glidern3.glidernet.org:10153', 
		'glidern4.glidernet.org:10153', 
		'glidern5.glidernet.org:10153', 
		'aprs.glidernet.org:10152' );
#
#############
#
# setup
#
#############
#
# Flush after each write
my $old_handle = select (STDOUT); # "select" STDOUT and save
                                  # previously selected handle
$| = 1; # perform flush after each write to STDOUT
select ($old_handle); # restore previously selected handle

sub NESW { my @x = (deg2rad(90 - $_[1]), deg2rad($_[0])); return \@x; };


my %stations_loc : shared; # static cache to stop too many db updates
my %stations_ver : shared;

my %stations_last : shared;
my %stations_packets : shared; # same mutex as last
my %stations_status : shared; # same mutex, flags errors like no ppm
my %stations_ppm : shared; # same mutex, counts up until we are confident of noppm
my %stats : shared; #mutex
my %gliders : shared;

# caches for the insert into db so we don't need to use text fields
my %station_id :shared;
my %station_name : shared;
my %glider_id :shared;

my $ready_semaphore = Thread::Semaphore->new(100); 
 
while(1) {
    $ready_semaphore->down(100);
    my $avail = threads->create( \&handleAvailablity );
    foreach my $server ( @servers ) {	
	my $name="localhost";
	if ($server =~ /glider*/ ) {
		$name=substr($server, 0, 22);
	}
	if ($server =~ /aprs*/ )
	{
		$name=substr($server, 0, 18);
	}
	$address = inet_ntoa(inet_aton($name));
	print "\n<<<< Connecting Server: $server  at IP addr: $address <<<<\n";
	threads->create( \&handleServer, $server );
    }
    
    $avail->join();
}

##############
# connect to  server and process the data from it 
##############
sub handleServer {
    my ($server) = @_;


    # wait for us to be ready to start, we will be signalled by the availability thread once it has loaded
    # everything
    $ready_semaphore->down(1);

    my $full =  ! ($server =~ /^aprs/);

    my $db = DBI->connect( $db_dsn, $db_username, $db_password );
    if( ! $db ) {
	die "==> database problem serving: $server ". $DBI::errstr;
    }
    $db->do( 'SET time_zone = "+00:00"' );


    my $sth_mgrs = $db->prepare( 'insert into positions_mgrs values ( left(now(),10), ?, ?, ?, ?, ?, 1 ) on '.
				' duplicate key update strength = greatest(values(strength),strength), '.
				' lowest = least(values(lowest),lowest), highest=greatest(values(highest),highest), '.
				' count= count+1' );

#    my $sth_crc = $db->prepare( 'insert into crc values ( now(), ?, ?, ?, ?, ?, ?, ?, ? );' );
    
    my $sth_addstation    = $db->prepare( 'insert into stations ( station ) values ( ? )' );
    my $sth_updatestation = $db->prepare( 'update stations set station = ? where id = ?' );
    my $sth_addglider     = $db->prepare( 'insert into gliders ( callsign ) values ( ? )' );
    my $sth_history       = $db->prepare( 'insert into history values ( now(), ?, ?, ? )' );

    my $name   =  "localhost";
    if ($server =~ /glider*/ )
	{
		$name=substr($server, 0, 22);
	}
    if ($server =~ /aprs*/)
	{
		$name=substr($server, 0, 18);
	}
    my $address = inet_ntoa(inet_aton($name));
    if ($prt) {print "connecting to server $server at IP addr: $address \n";}
    my $is = new Ham::APRS::IS( $server, 'OGNRANGE', 'appid' => 'ognrange.glidernet.org 0.4.0');

    open( OUT, ">>", "/dev/null" );
#    open( OUT, ">>", $server );

    my $i = 0;
    my $lastkeepalive = time();
    my $today = date($lastkeepalive);
    my $alive    = "/nfs/OGN/DIRdata/OGNRANGE.alive";

    while(1) {
	$is->connect('retryuntil' => 10) || print "Failed to connect: $is->{error}";

	if   ($is->connected()) {$is->sock()->setsockopt(SOL_SOCKET,SO_RCVBUF,256*1024);}
	
	while($is->connected()) {
	   
    	    if (not $db->ping()) {
		$db->disconnect();
		warn "\n >>>> Reconnecting MySQL for server $server <<<<\n\n";
    	    	$db = DBI->connect( $db_dsn, $db_username, $db_password );
    		if( ! $db ) {
        			die "===> database problem serving $server ===>". $DBI::errstr;
    		}
    		$db->do( 'SET time_zone = "+00:00"' );	
	    }		
	    # make sure we send a keep alive every 90 seconds or so
	    my $now = time();
	    if( $now - $lastkeepalive > 60 ) {
		$is->sendline('# ognrange.glidernet.org 51.254.32.187 ');
		$lastkeepalive = $now;

                open(my $alive_fh,">>", $alive) or die "Can not create ALIVE file";
                print $alive_fh ">>>>>>> $now >>>>>>> $server >>>>>>>>>>>>>>";
                close   ($alive_fh);
	    }
	    
	    # check to make sure we emit the stations at least once a day
	    if( date($now) ne $today ) { 
		$today = date($now);
		if ( ! $full) {			# only the aprs.glidernet.org thread !!!
			%stations_loc = (); %stations_ver = ();
			if ($prt) {print "resetting stations for change of date";}
			my $starttime=$now;
			print OUT "\n-------New date: -------- $today ---------------\n";
			warn      "\n-------New date: -------- $server $today ---------------\n";
			warn      "\n-------New date: -------- $now   ---------------\n";

		# hide old stations so they don't linger forever
			$db->do( "create temporary table z as select sl.station, datediff(now(),max(sl.time)) a, least(greatest(5,count(sl.time)*2),21) b from stationlocation sl group by 1 having a > b" );
			$db->do( "update stations set active='N' where id = (select station from z where z.station = stations.id)" );
			$db->do( "drop temporary table z" );

		# ensure we have up to date coverage map once a day
			$db->do ( "truncate estimatedcoverage " );
			$db->do ( "insert into estimatedcoverage select station, ref, avg(strength) s,sum(count) c from positions_mgrs p group by station, ref having (s > 75 and c > 20) or s > 105" );
			$db->do ( "truncate roughcoverage " );
			$db->do ( "insert into roughcoverage select station, concat(left(ref,6),mid(ref,8,1)) r, avg(strength) s,sum(count) c from positions_mgrs p group by station, r " );
	    		my $now = time();
			my $totaltime = $starttime - $now;
			my $datestring = localtime();
			print     "--------------  Local date and time $datestring --------\n";
			warn      "--------------- $server $now $totaltime  ---------------\n";
		}
	    }

	    
	    my $l = $is->getline(120);
	    if (!defined $l) {
		if ($prt) {print "\n".date($now).": $server: failed getline: ".$is->{'error'}."\n";}
		$is->disconnect();
		last;
	    }
	    $i++;
	    print OUT $l."\n";

	    
	    if( $l =~ /^\s*#/ || $l eq '' || substr ($l,0,3) eq 'FNT') {
#		if ($prt) {print "\n$l\n";}
		next;
	    }

	    if( $full ) {
		$l =~ /^dup\s+(.*)$/;
		if ($prt) {print "\n->".$1."<-\n";}
		$l = $1;
	    }

	    
	    my %packetdata;
	    my $retval = parseaprs($l, \%packetdata);
	    
	    if ($retval == 1) {
		
		my $callsign = $packetdata{srccallsign};
		
		# we need to do the calculation for each station that matches
		foreach my $value (@{$packetdata{digipeaters}}) {
		    while (my ($k1,$v1) = each(%{$value})) {
			
			next if( $k1 ne 'call' );
			next if( $v1 =~ /GLIDERN[0-9]/ || $v1 eq 'TCPIP' || $v1 eq 'qAS');
			
			if( $v1 ne 'qAC' ) {

			    # if we know where the glider is then we will use that
			    if( $packetdata{type} eq 'location' && 
				$packetdata{latitude} && $packetdata{longitude} ) {
				
				my $lt = $packetdata{latitude};
				my $lg = $packetdata{longitude};
                                next if ($lt > 80.0 || $lt < -80.0 || $lg > 180.0 || $lg < -180.0);
				my ($lt_r,$lg_r) = makeLocationCoarse( $lt, $lg, 1000 );
				
				$lt_r = int(($lt_r * 1000)+.5)/1000;
				$lg_r = int(($lg_r * 1000)+.5)/1000;

				my $s_id = getStation( $sth_addstation, $sth_history, $sth_updatestation, $v1 );
				my $s_callsign = getGlider( $sth_addglider, $callsign );
				
				if( ($packetdata{comment}||'') =~ /([0-9.]+)dB ([0-9])e/ )  {
				    my $strength = int(($1+0) * 10);
				    my $height = int($packetdata{altitude});
				    my $direction = 1 << int(($packetdata{course}||0) / 11.25);
				    my $crc = $2+0;
				 
				    my $location = latlon_to_mgrs(23,$lt,$lg);

				    # shrink it down to what we actually want which is a subset
				    # 30UXC0006118429 -> 30UXC 00 18
				    $location =~ /^([0-9]|)([0-9][A-Z]{3}[0-9][0-9])[0-9]{3}([0-9]{2})/;
				    my $reduced = ($1||'0'); $reduced .= $2.$3;

				    # and store the record in the db
				    if ($s_id > 0) {$sth_mgrs->execute( $s_id, $reduced, $strength, $height, $height ) or warn "Can't execute statement: $DBI::errstr";;}

				    if( $full ) {
					if ($prt) {print "DUP: $s_callsign $s_id ($v1) lt='$lt_r' and lg='$lg_r'\n";}
				    }
				    
				    {
					lock( %stations_last );

					# uptime statistics
					$stations_last{$v1} = $now;
					$stations_packets{$v1} ++;

					# overall statistics
					if( $stats{$s_id} ) {
					    $stats{$s_id}->{gliders}->{$s_callsign} = ($stats{$s_id}->{gliders}->{$s_callsign}||0)+1;
					}
					else {
					    $stats{$s_id} = shared_clone( { station => $s_id, 
									    gliders => shared_clone( { $s_callsign => 1 } ),
									    crc => ($crc >= 5 ? 1 : 0 ) } );
					}

					if( ($stations_status{$v1}||'U') eq 'N' ) {
					    if ($prt) {print "packet from $v1 which is currently shown as noppm\n";}
					    $stations_status{$v1} = 'U';
					    $stations_ppm{$v1} = 0;
					}
				    }

				    {
					lock(%gliders);
					if( ! $gliders{$s_callsign} ) {
					    $gliders{$s_callsign} = shared_clone( { $s_id => 1 } );
					}
					else {
					    $gliders{$s_callsign}->{$s_id}++;
					}
				    }
				}
				else {
				    if ($prt) {print "*";}
				    {
					lock( %stations_last );
					$stations_last{$v1} = $now;
					$stations_packets{$v1} ++;
				    }
				}

			    } # has a location
			}
			elsif( $v1 eq 'qAC' ) {

			    if ($prt) {print "-------------------- qAC ------------------------------------\n";}

			    # qAC seems to be the beacons
			    my $s_id = getStation( $sth_addstation, $sth_history, $sth_updatestation, $callsign );
			    
			    if( $packetdata{type} eq 'location' && 
				$packetdata{latitude} && $packetdata{longitude} ) {

				if ($prt) {print "location beacon $l\n";}

				processStationLocationBeacon( $db, $callsign, $s_id, $packetdata{latitude}, $packetdata{longitude}, $packetdata{altitude}, $packetdata{comment}||'' );

				if( $packetdata{comment} && $packetdata{comment} =~ /v0.2.[0-5]/ ) {
				    if ($prt) {print "OLD details beacon $///$packetdata{comment}l\n";}
				    processStationDetailsBeacon( $db, $callsign, $s_id, $packetdata{comment});
				}
			    }
			    else {
				if ($prt) {print "details beacon $l\n";}
				processStationDetailsBeacon( $db, $callsign, $s_id, $l );
			    }
			}
			elsif( $packetdata{'type'} eq 'status' ) {
			    		    print "status: $l\n";
			}
			else {
			    if ($prt) {print "\n--- new packet ---\n$l\n";}
			    while (my ($key, $value) = each(%packetdata)) {
				if ($prt) {print "$key: $value\n";}
			    }
			}
		    }
		}
	    }
	    else {
		if ($prt) {print "\n$server: --- bad packet --> \"$l\"\n";}
		if ($l =~ 'RND') {
			if ($prt) {print "Ignore RND pacakets"}
		}
		else {
			warn "Parsing failed: $packetdata{resultmsg} ($packetdata{resultcode}) <==== \n";
			warn "\n$server: --- bad packet --> \"$l\"\n";
		}
	    }
	}
	my $sock   = $is->sock();
	my $nownow = time();
	my $dt     = DateTime->now;
	my $dmy    = $dt->dmy;
	my $hms    = $dt->hms;
	my $name   =  "localhost";
	if ($server =~ /glider*/ )
	{
		$name=substr($server, 0, 22);
	}
	if ($server =~ /aprs*/)
	{
		$name=substr($server, 0, 18);
	}
	$address = inet_ntoa(inet_aton($name));
	print "\n>>>> reconnecting $server Server: $name is at IP: $address Date and UTC Time: $nownow  $dmy $hms <<<<\n";
	$is->disconnect() || print "Failed to disconnect: $is->{error}";
	sleep(30);
    }
}

sub getStation {
    my($sth_add,$sth_history,$sth_supdate,$station) = @_;
    my $s_id = undef;
    if ($station eq 'SPOT' || $station eq 'SPIDER' || $station eq 'INREACH' || $station eq "FLYMASTER" || $station eq 'NAVITER' || $station eq 'CAPTURS' || $station eq 'LT24' || $station eq 'SKYLINES' ) {
	return 0;
    }

    if ($station =~ /^FNB/ || $station =~ /^XCG/ ||  $station =~ /^XCC/ || $station =~ /^OGN*/ || $station =~ /^RELAY*/ || $station =~ /^RND/ || $station =~/^FLR/ || $station =~/^bSky/ || $station =~/^AIRS/) {
    	return 0;
    }

    # figure out how it's going into the database
    {
	lock(%station_id);
	if( ! ($s_id = $station_id{lc $station}) ) {

	    $sth_add->execute( $station ) or die "Can't execute statement: $DBI::errstr";;
	    $s_id = $sth_add->{mysql_insertid};
	    $station_id{lc $station} = $s_id;
	    $station_name{ lc $station } = $station;
	    if ($prt) {print "\nnew station $station => $s_id\n";}
	    if ($s_id > 0) {$sth_history->execute( $s_id, 'new', "New station $station" ) or warn "Can't execute statement: $DBI::errstr";;}
	}
	elsif( $sth_supdate && ($station_name{ lc $station }||$station) ne $station ) {
	    $sth_supdate->execute( $station, $s_id ) or warn "Can't execute statement: $DBI::errstr";;	
	    if ($prt) {print "\nrenamed station $station => $s_id\n";}
	    if ($s_id > 0) {$sth_history->execute( $s_id, 'renamed', $station_name{ lc $station } . " now $station" ) or warn "Can't execute statement: $DBI::errstr";;}
	    $station_name{ lc $station } = $station;
	}
	
    }

    return $s_id;
}

sub getGlider {
    my($sth_add,$id) = @_;
    my $s_id = undef;

    return 0;

    # figure out how it's going into the database
    {
	lock(%glider_id);
	if( ! ($s_id = $glider_id{uc $id}) ) {

	    $sth_add->execute( $id ) or die "Can't execute statement: $DBI::errstr";;
	    $s_id = $sth_add->{mysql_insertid};
	    $glider_id{uc $id} = $s_id;
	    if ($prt) {print "\nnew glider $id => $s_id\n";}
	}
    }

    return $s_id;
}

    
sub handleAvailablity {

    my $db = DBI->connect( $db_dsn, $db_username, $db_password );
    if( ! $db ) {
	die "database problem". $DBI::errstr;
    }
    $db->do( 'SET time_zone = "+00:00"' );
    
    my $sth_sids	= $db->prepare( 'select station, id from stations' );        $sth_sids->execute() or die "Can't execute statement: $DBI::errstr";;
    my $sth_gids	= $db->prepare( 'select glider_id, callsign from gliders' ); $sth_gids->execute() or die "Can't execute statement: $DBI::errstr";;
    my $sth 		= $db->prepare( 'insert into availability values ( ?, ?, ? ) on duplicate key update time = values(time), status = values(status)' );
    my $sth_active 	= $db->prepare( 'update stations set active="Y" where id = ? and active="N"' );
    my $sth_activetime 	= $db->prepare( 'update stations set active="Y" where otime + 360 > now() and active="N"' );
    my $sth_log 	= $db->prepare( 'insert into availability_log values ( ?, ?, ? )' );
    my $sth_first 	= $db->prepare( 'select s.station, time from stations s, availability a where s.id = a.station_id and a.status = "U"' ); $sth_first->execute() or die "Can't execute statement: $DBI::errstr";;
    my $sth_addstation 	= $db->prepare( 'insert into stations ( station ) values ( ? )' );
    my $sth_updatestation = $db->prepare( 'update stations set station = ? where id = ?' );
    my $sth_history 	= $db->prepare( 'insert into history values ( now(), ?, ?, ? )' );
    my $sth_timestamp 	= $db->prepare( 'SELECT concat(Date(now())," ",SEC_TO_TIME((TIME_TO_SEC(now()) DIV 300) * 300)) AS round_time' );
    my $sth_stats 	= $db->prepare( 'insert into stats values ( ?, ?, ?, ?, ?, ?, ?, ? )' );
    my $sth_statssummary =  $db->prepare( 'insert into statssummary values ( ?, ?, ?, ?, ?, ?, ?, ? ) on duplicate key update positions=values(positions),gliders=values(gliders),crc=values(crc),ignoredpositions=values(ignoredpositions),cpu=values(cpu),temp=values(temp),time=values(time)' );

    my %station_previous_check = ();
    my %station_up = ();
    my %station_current = ();
    
    # lookup all the stations so they are available
    my $t = $sth_sids->fetchall_hashref('station');
    foreach my $station ( keys %{$t} ) {
	$station_id{lc $station} = $t->{$station}->{id};
	$station_name{lc $station} = $station;
    }

    $t = $sth_gids->fetchall_hashref('callsign');
    foreach my $callsign ( keys %{$t} ) {
	$glider_id{uc $callsign} = $t->{$callsign}->{glider_id};
    }

    $t = $sth_first->fetchall_hashref('station');
    foreach my $station ( keys %{$t} ) {
	$station_previous_check{$station} = $t->{$station}->{time};
    }

    # tell all the threads they can start
    $ready_semaphore->up(100);

    my $statscounter = 0;

    while(1) {
	# only process every 5 minutes
	sleep(600);

	# get our timestamp, use db time
	$sth_timestamp->execute() or die "Can't execute statement: $DBI::errstr";;
	my ($timestamp) = $sth_timestamp->fetchrow_array();

	# copy and reset so we don't keep locked for long
	my %station_packets;
	{
	    lock( %stations_last );
	    %station_current = %stations_last;
	    %station_packets = %stations_packets;
	    %stations_last = ();
	    %stations_packets = ();
	}

	if(0)
	{
	    lock( %gliders );
	    foreach my $g ( keys %gliders ) {
		if( scalar( keys %{$gliders{$g}} ) > 1 ) {
		    if ($prt) {print "$g:" . Dumper( $gliders{$g} ) . "\n";}
		}
	    }
	    %gliders = ();
	}


	# if we are reporting stats then we need to run through all the gliders accumulated
	# do this every second scan
	my %pstats;
	{
	    lock( %stations_last );
	    foreach my $station ( values %stats ) {
		my $positions = 0; my $gliders = 0;
		foreach my $glider (values %{$station->{gliders}}) {
		    $positions += $glider;
		    $gliders++;
		}
#		if( $positions > 0 ) {
#		    print ":".$station->{station}."> $positions pos, $gliders gliders, ".($gliders ? (int(($positions||0)*10/$gliders)/10):0)."\n";
#		}
		$pstats{$station->{station}} = { gliders => $gliders, positions => $positions, station => $station->{station}, crc => $station->{crc},
						 cpu => ($station->{cpu}||0), temp => ($station->{temp}||0) };
	    }
	    %stats = ();
	}
	
	# add up how many contacts each glider had
	foreach my $station( values %pstats ) {
	    my $temper = 1;
	    if  (int($station->{temp}) <999)  {
		    $temper=int($station->{temp});
		    }
	    $sth_stats->execute       (  $timestamp, $station->{station}, $station->{positions}, $station->{gliders}, $station->{crc}, 0, int(($station->{cpu}||0)*10), $temper ) or die "Can't execute statement: $DBI::errstr";;
	    $sth_statssummary->execute(  $station->{station}, $timestamp, $station->{positions}, $station->{gliders}, $station->{crc}, 0, int(($station->{cpu}||0)*10), $temper ) or die "Can't execute statement: $DBI::errstr";;
	}

	my $now = time();
	my $nstup = 0;
	if ($prt) {print "\nup: ";}
	my @missing;
	foreach my $station ( sort keys %station_current ) {
	    my $last = $station_current{$station};
	    my $s_id = getStation( $sth_addstation, $sth_history, undef, $station );
	    if ($s_id == 0) { 
		    if( $station_id {lc $station}) { $s_id = $station_id {lc $station};}
		    if ($s_id >0) {print "YYY==>  $s_id $station \n";}
	    }
	    if ($prt) {print "$station [". ($station_packets{$station}||0)."]";}
	    # if we didn't have a previous status it's a new station
	    if( ! ($station_previous_check{$station}||0) ) {
		if ($s_id > 0) {$sth_log->execute( $s_id, $last, 'U' ) or die "Can't execute statement: $DBI::errstr";;}
		push( @missing, $station );
		if ($prt) {print " (logged UP)";}
		$nstup = $nstup +1;
	    }
	    if ($prt) {print ",";}

	    if ($s_id > 0) {
		    $sth->execute( $s_id, $last, 'U' ) or die "Can't execute statement: $DBI::errstr";;
	    	    $sth_active->execute( $s_id ) or die "Can't execute statement: $DBI::errstr";;
	    }
            $nstup = $nstup +1;
	}
	$sth_activetime->execute();
	if ($prt) {print "====> Number of active stations at: $now $nstup <====\n";}

	if ($prt) {print "done.\ndown: ";}
	my $nstdown = 0;
	foreach my $station ( sort keys %station_previous_check ) {
	    my $last = $station_current{$station}||0;
	    my $s_id = getStation( $sth_addstation, $sth_history, undef, $station );


	    # if it hasn't had a new time then we are down, 
	    # possibly once or possibly multiple times
	    if( ! $last ) {
		if ($prt) {print "$station";}
		if( $station_previous_check{$station} ) {
			if ($s_id > 0) {

		    		$sth->execute( $s_id, $now, 'D' );
		    		$sth_log->execute( $s_id, $now, 'D' );
			}
		    if ($prt) {print "  (logged down)";}
		    $nstdown = $nstdown + 1;
		}
		if ($prt) {print ",";}
	    }

	    $station_previous_check{$station} = $last;
	}
	if ($prt) {print "\n";}
	if ($prt) {print "====> Number of down stations at: $now $nstdown <====\n";}
	my $localtime = localtime();
	print "====> Number of down stations at: $now Local time: $localtime $nstdown <====\n";
	
	foreach my $station (@missing) {
	    $station_previous_check{$station} = $station_current{$station};
	}
    }
}

sub date {
    my @t = gmtime($_[0]);
    return sprintf( "%04d-%02d-%02d", ($t[5]+1900),($t[4]+1),$t[3]);
}

sub datet {
    my @t = gmtime($_[0]);
    return sprintf( "%04d-%02d-%02dT%02d:%02d:%02d", ($t[5]+1900),($t[4]+1),$t[3],$t[2],$2[1],$t[0]);
}


sub processStationLocationBeacon {
    my ($db,$callsign,$s_id,$lt,$lg,$altitude,$comment) = @_;

    if ($s_id == 0) {return;} 						# nthing to do
    
    my $st_station_loc   = $db->prepare('insert into stationlocation (time,station,lt,lg,height,country) values ( left(now(),10), ?, ?, ?, ?, ? ) on duplicate key update lt = values(lt), lg = values(lg), country=values(country)' );
    my $st_station_otime = $db->prepare('update stations set otime=now() where station = ? ;');
    
    lock( %stations_loc );
    if( ($stations_loc{$callsign}||'') ne "$lt/$lg" and $s_id > 0) {
	my $c = '';							#getCountry($lt,$lg)
	if ($altitude > 9999) {
		$altitude = 9999;
	}
	if ($s_id > 0) {$st_station_loc->execute( $s_id, $lt, $lg, $altitude, $c );}	# update the new location
	if ($prt) {print "station $callsign location update to $lt, $lg ($c)\n";}
	$stations_loc{$callsign} = "$lt/$lg";
    }
    if($s_id > 0) {$st_station_otime->execute($callsign);} 			# update the last heartbeat
}

sub processStationDetailsBeacon {
    my ($db,$callsign,$s_id,$comment) = @_;

    my $st_station_ver = $db->prepare( 'insert into stationlocation (time, station, version) values ( left(now(),10), ?,? ) on duplicate key update version=values(version)' );

    # qAC seems to be the beacons
    my $cpu = 0; my $ppm = 0; my $dbadj = 0; my $temp = 1;
    my $version = '?';
    if ($callsign =~ /^FNB*/ )
    	{
	return;
	}

    if ($callsign =~ /^XCG*/)
    	{
	return;
	}

    if( $comment =~ /v([0-9.]+[A-Z0-9a-z-]*)/ ) {
	$version = $1;
    }
    
    if( $comment =~ /PilotAware/ ) {
	$version = 0;
	return;
    }
    
    if( $comment =~ /CPU:([0-9.]+) / ) {
	$cpu = $1+0;
    }

    if( $comment =~ / ([0-9.]+C|) / ) {
	$temp = ($1||0)+0;
    }
    
    if( $comment =~ /RF:.[0-9]+(.[0-9.]+)ppm.(.[0-9.]+)dB/ ) {
	$ppm = $1+0;
	$dbadj = $2+0;
    }
    
    if( ! $version ) {
	if ($prt) {print "****** [!version] $callsign: ".($comment||'')."\n";}
    }
    
    {	
	lock( %stations_ver );
	if( ($stations_ver{$callsign}||'') ne "$version" and $s_id > 0) {
	    $st_station_ver->execute( $s_id, $version );
	    if ($prt) {print "station $callsign version update to ($version)\n";}
	    $stations_ver{$callsign} = "$version";
	}
    }
    
    if ($prt) {printf (":::: %20s: ppm %0.1f %0.1f db [%-70s]\n", $callsign,($ppm||-99),($dbadj||-99),$comment);}
    
    if( defined($ppm) && defined($dbadj) )
    {
	lock( %stations_last );

	# statistics object
	my $statsobject = $stats{$s_id};
	if( ! defined($statsobject)) {
	    $statsobject = $stats{$s_id} = shared_clone( { station => $s_id, 
							   crc => 0,
							   gliders => shared_clone( { } ),
							   cpu => 0, 
							   temp => -273 } );
	}
	$statsobject->{cpu} = $cpu;
	$statsobject->{temp} = $temp;
	
	if( ! $ppm && ! $dbadj ) {
	    if( $cpu < 0.1 ) {
		$stations_ppm{$callsign} ++;
		if ($prt) {print "$callsign: LOWCPU & noppm (flagged $stations_ppm{$callsign} times)". $comment.">>cpu $cpu $ppm ppm, $dbadj db \n";}
		
		if( $stations_ppm{$callsign} > 10 ) { 
		    $stations_status{$callsign} = 'N';
#		    $sth_history->execute( getStation( $sth_addstation, $sth_history, $sth_updatestation, $callsign ), 
#					   'noppm', "Station $callsign has low CPU and NOPPM adjustment" );
		}
	    }
	}
	else {
	    $stations_ppm{$callsign} = 0;
	    $stations_last{$callsign} = time();
	    $stations_status{$callsign} = 'U';
	}
    }
}


