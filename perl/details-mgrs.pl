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
    my $position = param('position');

    if( ! ( $position =~ /^[A-Z0-9]+$/ )) {
	print header( -type=>'text/plain' ) . "invalid position";
    }
 
    my $db = DBI->connect( $db_dsn, $db_username, $db_password );

    if( ! $db ) {
	print header( -type=>'text/plain',
		      -expires=>'+1m' );
	print "database problem". $DBI::errstr;
	exit;
    }
    $db->do( 'SET time_zone = "GMT"' );

    
    my $sth =  $db->prepare( 'select s.station, sum(strength), min(lowest), max(highest), count(strength), sum(count), avg(strength), min(time), max(time) '.
			     ' from positions_mgrs p left outer join stations s on p.station = s.id '.
			     ' where (time between ? and  ?) and ref = ?  group by 1 order by 7 desc' );

    if( ! $sth->execute( $start, $end, $position ) ) {
	print header( -type=>'text/plain',
		      -expires=>'+1m' );
	print "database problem". $sth->errstr;
	exit;
    }

    print header( -type=>'application/json',
		  -expires=>'+1h' );

    printf( '{"query":{"start":"%s","end":"%s","ref":"%s"},"position":[', $start, $end, $position );
    
    my $rows = []; # cache for batches of rows
    my $count = 0;
    while( my $row = ( shift(@$rows) || # get row from cache, or reload cache:
		       shift(@{$rows=$sth->fetchall_arrayref(undef,10_000)||[]}) )
	) {

	if( $count ) {
	    print ',';
	}
	$count++;

	printf( '{"s":"%s","l":%d,"h":%d,"a":%d,"g":%d,"c":%d,"first":"%s","last":"%s"}',
		$row->[0], $row->[2], $row->[3], int($row->[1]/$row->[4]), $row->[4], $row->[5], $row->[7], $row->[8] );

    }

    print ']}';
	     
}

