package LatLngCoarse2;

use strict;
use warnings;
use Math::Trig qw(deg2rad rad2deg :pi);


our $VERSION = '1.0';
use base 'Exporter';

our @EXPORT = qw( makeLocationCoarse );


sub makeLocationCoarse {
    my ($lt,$lg,$granularityInMeters) = @_;

    if( $lt == 0 && $lg == 0 ) 
    {
    }
    else
    {
      my $granularityLat = 0;
      my $granularityLon = 0;
      my $OgranularityLat;
      my $OgranularityLon;

      {
	  my $angleUpInRadians = 0;
	  my ($new_lt, undef) =  getLocationOffsetBy($lt, $lg,
						     $granularityInMeters, $angleUpInRadians);
	  
	  $granularityLat = $lt - $new_lt;
	  
	  $OgranularityLat = $granularityLat;
	  if($granularityLat < 0) {
	      $granularityLat = -$granularityLat;
	  }
	  
	  my $angleRightInRadians = pi/2;
	  my (undef, $new_lg) =  getLocationOffsetBy($new_lt, $lg,
						     $granularityInMeters, $angleRightInRadians);
	  $granularityLon = $lg - $new_lg;
	  
	  $OgranularityLon = $granularityLon;
	  if( $granularityLon < 0) {
	      $granularityLon = -$granularityLon;
	  }
      }

      if($granularityLon == 0 || $granularityLat == 0)
      {
          $lt = $lg = 0;
      }
      else
      {
	  my $origin_lt = int($lt / $granularityLat) * $granularityLat;
	  my $origin_lg = int($lg / $granularityLon) * $granularityLon;

#	  print "origin:".$origin_lt.",".$origin_lg."\n";
#	  print "int origin:".($lt/$granularityLat).",".($lg/$granularityLon)."\n";
#	  print "gran:".$granularityLat.",".$granularityLon."\n";

	  # now move it to the centre rather than the corner
	  my $angleUpDownInRadians = $lt < 0 ? pi : 0;  # pi, 0
	  my ($new_lt,undef) = getLocationOffsetBy($origin_lt, $origin_lg,
						   $granularityInMeters/2, $angleUpDownInRadians);
    
	  my $angleAccrossInRadians = $lg < 0 ? pi+pi/2 : pi/2; # pi+1/2pi, 1/2pi 
	  my (undef,$new_lg) = getLocationOffsetBy($new_lt,$origin_lg,
						   $granularityInMeters/2, $angleAccrossInRadians);
	  
#	  print "res:".$new_lt.",".$new_lg."\n";
	  ($lt,$lg) = (int($new_lt*1000+0.5)/1000,int($new_lg*1000+0.5)/1000);
      }
    }

    return ($lt,$lg);
  }

sub asin { atan2($_[0], sqrt(1 - $_[0] * $_[0])) }

#  // http://www.movable-type.co.uk/scripts/latlong.html
#sub getLocationOffsetBy(const Location& location,
#    double offsetInMeters, double angleInRadians)
sub getLocationOffsetBy {
    my ($lt,$lg,$offsetInMeters,$angleInRadians) = @_;

    my $lat1 = deg2rad($lt);
    my $lon1 = deg2rad($lg);

    my $distanceKm = $offsetInMeters / 1000;
    my $earthRadiusKm = 6371;

    my $lat2 = asin( sin($lat1)*cos($distanceKm/$earthRadiusKm) + 
      cos($lat1)*sin($distanceKm/$earthRadiusKm)*cos($angleInRadians) );

    my $lon2 = $lon1 + 
      atan2(sin($angleInRadians)*sin($distanceKm/$earthRadiusKm)*cos($lat1), 
      cos($distanceKm/$earthRadiusKm)-sin($lat1)*sin($lat2));

    return (rad2deg($lat2),rad2deg($lon2));
  }

1;
