#!/usr/local/bin/perl

#
# this script accepts an image, resizes to specified maximum size
# and then puts links in the database refering to it
#


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
    my $station = param('station')||'';

    my $tile = param('squares')||'';

    my $glider = param('glider')||'';

    if( ! ( $tile =~ /^[A-Z0-9,]+$/ )) {
	print header( -type=>'text/plain' ) . "invalid tile list";
	exit;
    }

    if( ! ( $station =~ /^[A-Z0-9%_;]*$/i )) {
	print header( -type=>'text/plain' ) . "invalid station identifier/query string";
	exit;
    }

    my $db = DBI->connect( $db_dsn, $db_username, $db_password );
    if( ! $db ) {
	print header( -type=>'text/plain',
		      -expires=>'+1m' );
	print "database problem". $DBI::errstr;
	exit;
    }
    $db->do( 'SET time_zone = "GMT"' );

    my $sth;
    if( $station eq '' ) {
	$sth =  $db->prepare( 'select ref, sum(strength), count(*) glider from positions_mgrs '.
			     ' where ref like ? and (time between ? and  ?) group by 1' );

	if( ! $sth->execute( $tile.'%', $start, $end ) ) {
	    print header( -type=>'text/html' );
	    print "database problem". $sth->errstr;
	    exit;
	}
    }
    else {
	my $stationquery = ' = ? ';
	if( $station =~ /;/ ) {
	    my @stationlist = split( /;/, $station );
	    $stationquery = ' in ( '."?,"x(scalar @stationlist) .',"") ';
	    $station = \@stationlist;
	}
	elsif ( $station =~ /%/ ) {
	    $stationquery = ' like ? ';
	}

	
	$sth =  $db->prepare( 'select ref, sum(strength), count(*) glider from positions_mgrs p, stations s '.
			      ' where s.station '.$stationquery.' and p.station = s.id and ref like ? and (time between ? and  ?) group by 1' );
	
	if( ! $sth->execute( $station, ($tile.'%'), $start, $end  ) ) {
	    print header( -type=>'text/html' );
	    print "database problem". $sth->errstr;
	    exit;
	}
    }


    print header( -type=>'application/json',
		  -expires=>($station ? '+30m' : '+2h') );
#		  -expires=>'1s' );
    print '{';
    print '"t":"'.$tile.'",';
    print '"p":[';
    
    my $rows = []; # cache for batches of rows
    my $count = 0;
    while( my $row = ( shift(@$rows) || # get row from cache, or reload cache:
		       shift(@{$rows=$sth->fetchall_arrayref(undef,10_000)||[]}) )
	) {

	if( $count ) {
	    print ',';
	}
	$count++;
	printf( '"%s/%d"',substr($row->[0],-4), int($row->[1]/$row->[2]));
    }

    print ']}';
	     
}

