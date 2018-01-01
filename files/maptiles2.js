function CoverageMapType(tileSize,map) {
  this.tileSize = tileSize;
  this.projection = new MercatorProjection( tileSize.width );
  this.start = '2014-04-14';
  this.end = '2200-01-01';
  this.station = "";
  this.source = "max";
  this.ambiguity = false;
  this.colours = [];
  this.alpha = [];
  this.colour = '';
    this.map = map;
//  this.setColourScheme( '#00990000:#009900ff' );
}

var id = 0;
var cache = {};
var cacheUTM = {};

CoverageMapType.prototype.setStation = function(newStation,clipping) {
    this.clipping = clipping;
    this.station = newStation;
}

CoverageMapType.prototype.setColourScheme = function(_colour) {
    this.colour = _colour;
    var s = _colour.split( ':' );
    
    var start = tinycolor( s[1] ); start = start.toRgb();
    var end = tinycolor( s[0] ); end = end.toRgb();

    console.log( _colour );
    console.log( "start:" );
    console.log( start );
    
    for (i = 0; i < 25; i++) {
	var alphablend = 1-(i/24);
	var c = { r: start.r * alphablend + (1 - alphablend) * end.r,
		  g: start.g * alphablend + (1 - alphablend) * end.g,
		  b: start.b * alphablend + (1 - alphablend) * end.b,
		  a: start.a * alphablend + (1 - alphablend) * end.a };

	this.colours[i] = tinycolor(c).toRgbString();
    }
}

CoverageMapType.prototype.setDates = function(_start,_end) {
    this.start = _start;
    this.end = _end;
}

CoverageMapType.prototype.setSource = function(_source) {
    this.source = _source;
}

CoverageMapType.prototype.setAmbiguity = function(_ambiguity) { 
    this.ambiguity = _ambiguity;
}

function doRound(x) {
    return Math.round(x*1000)/1000;
}

CoverageMapType.prototype.getTile = function(coord, zoom, ownerDocument) {

    // do nothing if too much out zoom
    if( zoom < 8 && this.source != 'lowres-coverage' )  {
	var div = ownerDocument.createElement('div');
	div.style.width = this.tileSize.width + 'px';
	div.style.height = this.tileSize.height + 'px';
	return div;
    }
    
    var numTiles = 1 << zoom;

    // this is the top left corner
    var xtop = ((coord.x) * this.tileSize.width)/numTiles;
    var ytop = ((coord.y) * this.tileSize.height)/numTiles
    var tileSize = this.tileSize.width;

    var fetchxtop = ((coord.x-.1) * this.tileSize.width)/numTiles;
    var fetchytop = ((coord.y-.1) * this.tileSize.height)/numTiles
    var fetchxbottom = ((coord.x+1.2) * this.tileSize.width)/numTiles
    var fetchybottom = ((coord.y+1.1) * this.tileSize.height)/numTiles;
    
    var tl_exact = this.projection.fromPointToLatLng(new google.maps.Point(xtop, ytop ));
    var br_exact = this.projection.fromPointToLatLng(new google.maps.Point( (coord.x+1)*this.tileSize.width/numTiles, (coord.y+1)*this.tileSize.height/numTiles ));

    var fetchtl = this.projection.fromPointToLatLng(new google.maps.Point(fetchxtop, fetchytop ));
    var br = this.projection.fromPointToLatLng(new google.maps.Point(fetchxbottom, fetchybottom ));
    var projection = this.projection;
        


    // next is to figure out what to plot there
    var div = ownerDocument.createElement('div');
    div.style.width = this.tileSize.width + 'px';
    div.style.height = this.tileSize.height + 'px';

    // helps with debugging
    id = id+1;
    var id_x = id;

    var canvas = ownerDocument.createElement('canvas');
    div.appendChild(canvas);
    canvas.width = this.tileSize.width;
    canvas.height = this.tileSize.height;


    if( 0 ){
	div.style.borderStyle = 'solid';
	div.style.borderWidth = '1px';
	div.style.borderColor = '#AAAAAA'; 
    }
    
 //   div.innerHTML = tl + "_" + id_x;
    var station = this.station;
    var start = this.start;
    var end = this.end;
    var ambiguity = this.ambiguity;
    var alpha = this.alpha;
    var colours = this.colours;
    var context = canvas.getContext('2d');
    var zoom = this.map.getZoom();

    // always draw ambiguity regardless
    if( ambiguity && tl_exact.lat() > 45 && br_exact.lat() > 45 ) {
	    
	var toScreen = function(ltlg) {
	    var s = projection.fromLatLngToPoint(ltlg);
	    return new google.maps.Point(  (s.x - xtop) * numTiles, (s.y - ytop) * numTiles );
	}
	
	// lets draw the lines
	context.strokeStyle = 'red';
	for( var t = (br_exact.lat() * 10000000 / (128*32768))|0, 
	     r = ((tl_exact.lat() * 10000000 / (128*32768))|0)+1; t <= r; t++) {
	    
	    var s = toScreen(new google.maps.LatLng( t * 128*32768 / 10000000, tl_exact.lng()  ));
	    var f = toScreen(new google.maps.LatLng( t * 128*32768 / 10000000, br_exact.lng()  ));
	    
	    context.beginPath();
	    context.moveTo(s.x,s.y);
	    context.lineTo(f.x,f.y);
	    context.stroke();
	}
	
	var scale_factor = ((tl_exact.lat() <= 45 ? 128 : 256) * 32768);
	
	for( var t = (tl_exact.lng() * 10000000 / (scale_factor))|0, 
	     r = ((br_exact.lng() * 10000000 / (scale_factor))|0)+1; t <= r; t++) {
	    
	    var s = toScreen(new google.maps.LatLng( tl_exact.lat(), t * scale_factor / 10000000 ));
	    var f = toScreen(new google.maps.LatLng( br_exact.lng(), t * scale_factor / 10000000 ));
	    
	    context.beginPath();
	    context.moveTo(s.x,s.y);
	    context.lineTo(f.x,f.y);
	    context.stroke();
	}
    }


    // if we are more than 110 km away then we won't plot this grid so just save the bandwidth and do nothing
    if( this.clipping ) {
	var distance = Math.min(google.maps.geometry.spherical.computeDistanceBetween(this.clipping,fetchtl),
				google.maps.geometry.spherical.computeDistanceBetween(this.clipping,br));
	
	if( distance > 200*1000 ) { /*100km*/
//	    console.log( "clipping on "+this.clipping.toString()+" we are "+(distance/1000)+"km away ("+id_x+")" );
	    return;
	}
    }
    
//    var offsetX = 0;- ((2<<(zoom - 8))*0.045+0.7);
//    var offsetY = 0;- ((2<<(zoom - 8))*0.045+0.2);
    
    // plot a square that has been fetched
    function plotRef(json) {
		
	function convert(lt,lg) {
	    var point = projection.fromLatLngToPoint( new google.maps.LatLng(lt,lg));
	    return new google.maps.Point( (point.x - xtop)*numTiles, (point.y - ytop)*numTiles );
	}
	
	function fillBox(x) {
	    var tl = convert(x[1],x[0]); var br = convert(x[3],x[2]);
	    if( (tl.x < 0 && br.x < 0) || (tl.y < 0 && br.y < 0) ||
		(tl.x > tileSize && br.x > tileSize) || (tl.y > tileSize && br.y > tileSize ) ) {
		return;
	    }
	    context.fillRect( tl.x, tl.y, br.x - tl.x, br.y - tl.y );
	}

	if( colours.length > 0 && json.p ) {

	    // expand out the data - smaller over the network like this and I don't care so much about
	    // the poor browsers
	    var points = [];
	    json.p.forEach( function(position) {
		var data = position.split('/');
		var mgrs = json.t + data[0];
		points.push( { a: data[1], m: mgrs } );
		if( ! cacheUTM[ mgrs ] ) {
		    cacheUTM[ mgrs ] = inverse( mgrs );
		}
	    } );

	    context.globalAlpha = 1;
	    context.lineWidth = 0.2;
	    for( var i = 250, p = 1000000, n = 0; i >= 10; p = i, i-=10, n++ ) {
		context.fillStyle = context.strokeStyle = colours[ n ];
		var t = i/5;
		
		points.forEach( function(position) {
		    if( position.a >= i && position.a < p ) {
			fillBox( cacheUTM[ position.m ] );
		    }
		});
	    }
	}
    };
	

    var tiles = {};
    for( var x = Math.min(tl_exact.lng(),br.lng()), xm = Math.max(tl_exact.lng(),br.lng()); x <= xm ;x+= 0.1 ) {
	for( var y = Math.min(br.lat(),tl_exact.lat()), ym = Math.max(br.lat(),tl_exact.lat())+0.25; y <= ym; y+= 0.1 ) {
	    tiles[ forward([x,y],1).substr(0,5) ] = 1;
	}
    }

    var source = this.source;

    // fetch each square
    Object.keys(tiles).sort().forEach( function(tile) {
	var cacheKey = 	tile+source+station+start+end;
	if( ! cache[cacheKey] ) {
	    cache[cacheKey] = [ plotRef ];

	    $.ajax({   type: "GET",
		       url: "/perl/"+source+"-tile-mgrs.pl",
		       data: { station: station, start: start, end: end, squares: tile},
		       timeout:20000,
		       cache: true,
		       error: function (xhr, ajaxOptions, thrownError) {
		       },
		       success: function(json) { 
			   cache[cacheKey].forEach( function(x) { x(json); } ); cache[cacheKey] = undefined; }
		   });
	}
	else {
	    cache[cacheKey].push( plotRef );
	}
    });

    return div;
};


function bound(value, opt_min, opt_max) {
  if (opt_min != null) value = Math.max(value, opt_min);
  if (opt_max != null) value = Math.min(value, opt_max);
  return value;
}


function degreesToRadians(deg) {
  return deg * (Math.PI / 180);
}

function radiansToDegrees(rad) {
  return rad / (Math.PI / 180);
}

/** @constructor */
function MercatorProjection(tile_size) {
  this.pixelOrigin_ = new google.maps.Point(tile_size / 2,
      tile_size / 2);
  this.pixelsPerLonDegree_ = tile_size / 360;
  this.pixelsPerLonRadian_ = tile_size / (2 * Math.PI);
}

MercatorProjection.prototype.fromLatLngToPoint = function(latLng,
    opt_point) {
  var me = this;
  var point = opt_point || new google.maps.Point(0, 0);
  var origin = me.pixelOrigin_;

  point.x = origin.x + latLng.lng() * me.pixelsPerLonDegree_;

  // Truncating to 0.9999 effectively limits latitude to 89.189. This is
  // about a third of a tile past the edge of the world tile.
  var siny = bound(Math.sin(degreesToRadians(latLng.lat())), -0.9999,
      0.9999);
  point.y = origin.y + 0.5 * Math.log((1 + siny) / (1 - siny)) *
      -me.pixelsPerLonRadian_;
  return point;
};

MercatorProjection.prototype.metresPerPixel = function(latlng,zoom) {
    return 0.009330692 * (1 << (24-zoom)) * Math.cos( degreesToRadians(latlng.lat()));
}

MercatorProjection.prototype.fromPointToLatLng = function(point) {
  var me = this;
  var origin = me.pixelOrigin_;
  var lng = (point.x - origin.x) / me.pixelsPerLonDegree_;
  var latRadians = (point.y - origin.y) / -me.pixelsPerLonRadian_;
  var lat = radiansToDegrees(2 * Math.atan(Math.exp(latRadians)) -
      Math.PI / 2);
  return new google.maps.LatLng(lat, lng);
};



