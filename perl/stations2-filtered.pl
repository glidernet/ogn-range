#!/usr/local/bin/perl


# Copyright (c) 2014-2018, Melissa Jenkins
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

use CGI qw/:standard/;
use DBI;
use Date::Parse;
use JSON;

# load the configuration file
my $filename = "$ENV{RANGEPATH}/config/webconfig.json";

my $json_text = do {
    open(my $json_fh, "<:encoding(UTF-8)", $filename)
	or die("Can't open \"$filename\": $!\n");
    local $/;
    <$json_fh>
};

my $json = JSON->new;
my $data = $json->decode($json_text);

my $db_dsn = $data->{config}->{dsn} || die "no dsn specified";
my $db_username = $data->{config}->{dbusername} || die "no user specified";
my $db_password = $data->{config}->{dbpassword} || die "no user specified";



if( param ) {

    my $start = param('start');
    my $end = param('end');

    if( ! $end || $end eq '' || ! $end =~ /20[0-3][0-9]-[0-1][0-9]-[0-1][0-9]/ ) {
	$end = '2100-01-01';
    }

    if( ! $start || $start eq '' || ! $start =~ /20[0-3][0-9]-[0-1][0-9]-[0-1][0-9]/ ) {
	$start = '2014-01-01';
    }

    my $db = DBI->connect( $db_dsn, $db_username, $db_password );
    if( ! $db ) {
	print header( -type=>'text/plain',
		      -expires=>'+1m' );
	print "database problem". $DBI::errstr;
	exit;
    }
    $db->do( 'SET time_zone = "+00:00"' );

    print header( -type=>'application/json',
		  -expires=>'+2m' );

    $db->do(' set time_zone = "+00:00"');
    $db->do(' set session sql_mode="STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"');
    my $sth_station    = $db->prepare(' select o.station,sl.lt,sl.lg,a.status, left(o.otime,16),o.active, version  from stations o left join availability a on o.id = a.station_id , stationlocation sl where  o.id = sl.station and sl.lt is not NULL  and o.otime > "2000-01-01" and  sl.time=(select max(i.time) from stationlocation i  where i.station=o.id and i.time between ? and ?)    group by o.station');

    $sth_station->execute( $start, $end );
	 
    print '{"stations":[';
    
    my $rows = []; # cache for batches of rows
    my $count = 0;
    while( my $row = ( shift(@$rows) || # get row from cache, or reload cache:
		       shift(@{$rows=$sth_station->fetchall_arrayref(undef,10_000)||[]}) )
	) {

	if( $count ) {
	    print ',';
	}
	$count++;

	if( ! defined($row->[3]) ) {
	    $row->[3] = 'D';
	}
	my $tdiff = 99999;
	if (defined($row->[4])) {
		$tdiff= time - str2time($row->[4]) ;
		#if ($row->[3] eq 'D') {print "\n\n >>>>>> ", $row->[0]," T: ", $tdiff, " UT: ", $row->[4], "\n";}
	}
				
	if ($row->[3] eq 'D' and $tdiff < 12000)
		{
			#warn "Station: $row->[0]  $row->[1]  $row->[2]  $row->[3] $row->[4] " ;
			$row->[3] = 'U';
		}

	printf( '{"s":"%s","lt":%.4f,"lg":%.4f,"u":"%s","ut":"%s","b":%d,"v":"%s"}', @{$row} );
    }

    print ']}';
	     
}

