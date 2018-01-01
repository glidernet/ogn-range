
var map;
//                       0 1  2   3  4  5  6  7  8  9
var position;
var lastPosition;
var stations = {};
var station_markers = {};
var labelled_markers = [];
var circles = [];
var timeoutId;
var airspaceOverlay;
var coverageOverlay;
var start = '2015-03-31';
var end = '2100-01-01';
var currentStation = '';
var lasthash = '';
var maxTimeout, minTimeout;
var processingUrl = true;

var selected = { 'what':'max', 'when':'all', 'station':'', 'airspace':'', 'circles':'', 'ambiguity':'', 'colour':':#00990000:#009900ff' };

function setup() {

  var mapOptions = {
      zoom: location.hash ? 9 : 4,
      center: new google.maps.LatLng(52.1290225,6.8567554),
      draggableCursor:'crosshair',
      mapTypeId: google.maps.MapTypeId.TERRAIN,
  };

    $(window).resize(function () {
	var h = $(window).height(),
        offsetTop = 60 + 80+20; // Calculate the top offset
	
	$('#map-canvas').css('height', (h - offsetTop));
    }).resize();


    map = new google.maps.Map(document.getElementById('map-canvas'),
			      mapOptions);

    var maxZoomLevel = 11;
    var minZoomLevel = 8;
    google.maps.event.addListener(map, 'zoom_changed', function() {
	console.log( map.getZoom () );
	if (map.getZoom() > maxZoomLevel) map.setZoom(maxZoomLevel);
	if (map.getZoom() < minZoomLevel) {
	    $('#zoom_msg').show();
	}
	else {
	    $('#zoom_msg').hide();
	}
	tick( 'zoom', map.getZoom() );
    });

/*    google.maps.event.addListener(map, 'mousemove', function(e) {
	$('#details').html( e.latLng.lat() + "," + e.latLng.lng() );
   });
*/


    google.maps.event.addListener(map, 'center_changed', function() {
	tick( 'center', map.getCenter().toUrlValue().replace(',','_') );
	tick( 'zoom', map.getZoom() );
	$('#details').hide();
    });

    google.maps.event.addListener(map, 'click', function(e) {
	$('#details').html('loading...');
	if( timeoutId ) { 
	    clearTimeout(timeoutId);
	}
	timeoutId = setTimeout( displayDetails, 500 );
	position = e.latLng;
    });

    airspaceOverlay = new google.maps.ImageMapType({
            getTileUrl: function(tile, zoom) {
		var initialResolution = 2 * Math.PI * 6378137 / 256;  // == 156543.0339
		var originShift = 2 * Math.PI * 6378137 / 2.0; // == 20037508.34
 
		var res = initialResolution / (1<<zoom);
		var tx= tile.x;
		var ty = ((1 << zoom) - tile.y - 1); // TMS
		var swlon = tx * 256 * res - originShift;
		var swlat = ty * 256 * res - originShift;
		var nelon = (tx+1)*256 * res - originShift;
		var nelat = (ty+1)*256 * res - originShift;
		var baseURL = "http://maps.openaip.net/geowebcache/service/wms?service=WMS&request=GetMap&version=1.1.1&layers=openaip_approved_airspaces_geometries&styles=&format=image/png&transparent=true&height=256&width=256&srs=EPSG:900913&bbox=";
		var url = baseURL + swlon + "," + swlat + "," + nelon + "," + nelat;
		return url;
		},
            maxZoom: 17,
            minZoom: 4,
            opacity: 0,
            tileSize: new google.maps.Size(256, 256)
        });

    coverageOverlay = new CoverageMapType(new google.maps.Size(256, 256), map );

    // Insert this overlay map type as the first overlay map type at
    // position 0. Note that all overlay map types appear on top of
    // their parent base map.
    map.overlayMapTypes.insertAt(0, coverageOverlay );

        
    if( location.hash.substr(1) != '' ) {
	readhash();
    }
    else {
	selected['circles']='circles'; // preserve old default on blank urls
	setColour( '#00990000:#009900ff' ); // original green colouring
	processingUrl = false;
    }


    // display the stations
    displayStations( true );

    $('#details').html("Blue icons represent UP old stations, Mauve ones DOWN<br/>Green is 0.2.1 or above and UP, Red is DOWN new stations");
    $('#details').show()

    $(window).bind( 'hashchange', readhash );
    
    timeoutId = null;
};


function displayStations(first) {
    $.ajax( {   type: "GET",
		url: "/perl/stations2-filtered.pl?start="+start+"&end="+end,
		timeout:20000,
		cache: true,
		error: function (xhr, ajaxOptions, thrownError) {
		},
		success: function(json) {
		    var checked = selected['circles'] == 'circles';

		    // remove old markers and prpeare for re-add
		    for( var entry in station_markers ) {
			station_markers[entry].setMap(null);
		    }
		    station_markers = {};
		    for( var entry in circles ) {
			circles[entry].setMap( null );
		    }
		    circles = [];

		    // add markers
		    json.stations.forEach( function(entry) {
			stations[entry.s] = entry;

			var old = (entry.v == 'old' || entry.v == '?' || entry.v == "undefined" || entry.v == "" || entry.v == '0.1.3' );
			var colour = '00ff00';
			if( entry.u == "U" ) {
			    if( old ) {
				colour = '0000ff';
			    }
			}
			else {
			    if( old ) {
				colour = 'aa00aa';
			    }
			    else {
				colour = 'aa0000';
			    }
			}
			
			var marker = station_markers[entry.s] = 
			    new google.maps.Marker({
			    position: (stations[entry.s].glatlng = new google.maps.LatLng( entry.lt, entry.lg )),
			    map: map,
				title: entry.s + "\n" + (entry.u == "U" ? "Up at " : "Last point at ") + entry.ut + "Z\n" + entry.b + " availability changes in 24hrs\n" +
				    "Version " + entry.v,
				
				icon: "//www.googlemapsmarkers.com/v1/" + colour + "/",
			});

			google.maps.event.addListener(marker, 'click', function() {
			    getStationData( entry.s );
			} );

			var rangeCircle = {
			    strokeColor: '#444',
			    strokeOpacity: 0.75,
			    strokeWeight: 1,
			    map: checked ? map : null,
			    fillColor: '#fff',
			    fillOpacity: 0,
			    center: new google.maps.LatLng( entry.lt, entry.lg ),
			    radius: 10000,
			    clickable:false,
			};
			// Add the circle for this city to the map.
			circles.push(new google.maps.Circle(rangeCircle));
			rangeCircle.strokeOpacity = 0.6;
			rangeCircle.radius = 20000;
			circles.push(new google.maps.Circle(rangeCircle));
			rangeCircle.radius = 30000;
			rangeCircle.strokeOpacity = 0.3;
			circles.push(new google.maps.Circle(rangeCircle));
		    } );

		    if( first ) {
			setupSearch();
			var stationName = $('#typeahead').val();
			if( stationName != "" && stations[stationName] ) {
			    map.setCenter( new google.maps.LatLng( stations[stationName].lt, stations[stationName].lg ) );
			}
		    }

		}
	    });

    // and update every 5 minutes
    setTimeout( displayStations, 150*1000 );
}

function getStationData( stationName ) {
    adjustMap( null, null, stationName );
    return false;
};


function displayDetails() {

    if( position && position != lastPosition ) {

	$.ajax( {   type: "GET",
		    url: "/perl/details-mgrs.pl",
		    data: { start: start, end: end, position: forward([position.lng(),position.lat()],2) },
		    timeout:20000,
		    cache: true,
		    error: function (xhr, ajaxOptions, thrownError) {
		    },
		    success: function(json) {
			console.log( json.toString() );

			var pos = inverse( json.query.ref );
			var bounds = new google.maps.LatLngBounds( new google.maps.LatLng(pos[1],pos[0]), new google.maps.LatLng(pos[3],pos[2]));
			var point = bounds.getCenter();

			labelled_markers.forEach( function(x) {
			    x.setIcon( x.originalIcon );
			});
			labelled_markers = [];
			
//			var stationList = "!"+forward([position.lng(),position.lat()],1) + ":" + position.lat() + "," + position.lng() + ">>" + json.query.ref + "<br/>";
			var stationList = "";
			var id = 1;
			var currentFilter = $('#typeahead').val();
			json.position.forEach( function(station) {
			    var distance = stations[station.s] ? Math.round(google.maps.geometry.spherical.computeDistanceBetween (stations[station.s].glatlng,point)/100)/10 : '?';
			    if( currentFilter != '' && station.s != currentFilter ) {
				stationList += "<i class='subtle'>";
			    }
			    stationList += "<b>"+id+":"+station.s+"</b>: "+distance+"km, "+station.l+"-"+station.h+"m, Avg Max:"+(station.a/10)+"db, Samples:"+station.c + ", Gliders:"+station.g+
				' ('+station.first;
			    
			    if( station.first != station.last ) {
				stationList +=  " to " + station.last;
			    }
			    stationList += ')<br/>';

			    if( currentFilter != '' && station.s != currentFilter ) {
				stationList += "</i>";
			    }
			    if( station_markers[station.s] ) {
				var oI = station_markers[ station.s ].originalIcon = station_markers[ station.s ].getIcon();
				station_markers[ station.s ].setIcon( oI.replace('/v1/', '/v1/'+id+'/') );
				labelled_markers.push( station_markers[ station.s ] );
			    }
			    id++;
			});
			console.log( stationList );
			$('#details').html(stationList);

			// swap details for the ad
			$('#ad').hide();
			$('#details').show()
		    },
		});

	lastPosition = position;
    }

    timeoutId = null;
}


var substringMatcher = function(strs) {
    return function findMatches(q, cb) {
	var matches, substringRegex;

	matches = [];
	substrRegex = new RegExp(q, 'i');
	for( var key in stations ) {
	    if (substrRegex.test(key)) {
		matches.push({ value: key });
	    }
	}
	
	cb(matches.sort(function(a,b){ return a.value < b.value ? -1 : (a.value == b.value ? 0 : 1); }));
	cb(matches);
    };
};

function setupSearch()   {
    $('.stationlist #typeahead').typeahead({   hint: true,
					       highlight: true,
					       minLength: 1
					   },
					   {
					       name: 'stations',
					       displayKey: 'value',
					       source: substringMatcher('')
					   });
}


function toggleCircles() {
    var newmap = null;
    if( selected['circles'] == '' ) {
	tick( 'circles', 'circles' );
	newmap = map;
    } 
    else {
	tick( 'circles', '' );
    }

    circles.forEach( function(c) {
	    c.setMap( newmap );
    });
    return false;
}

function toggleAirspace() {
    if( selected['airspace'] == '' ) {
	airspaceOverlay.setOpacity(1);
	map.overlayMapTypes.setAt(1, airspaceOverlay);
	tick( 'airspace', 'airspace' );
    } 
    else {
	airspaceOverlay.setOpacity(0); 
	map.overlayMapTypes.removeAt(1);
	tick( 'airspace', '' );
    }
    return false;
}

function toggleAmbiguity() {
    map.overlayMapTypes.removeAt(0);

    if( selected['ambiguity'] == '' ) {
	coverageOverlay.setAmbiguity(1);
	tick( 'ambiguity', 'ambiguity' );
	$('#details').html("<b>Currently only displays ambiguity squares above 45 degrees north</b>");
    } 
    else {
	coverageOverlay.setAmbiguity(0);
	tick( 'ambiguity', '' );
    }
    map.overlayMapTypes.insertAt(0, coverageOverlay);
    return false;
}

function setMinColour(c,a) {
    var s = selected['colour'].split(':');
    if( s[0] != c ) {
	s[0] = c+pad2(a.toString(16)); 
	adjustMap( null, null, null, s[0]+':'+s[1] );
    } 
    return false;
}

function setMaxColour(c,a) {
    var s = selected['colour'].split(':');
    if( s[1] != c ) {
	s[1] = c+pad2(a.toString(16)); 
	adjustMap( null, null, null, s[0]+':'+s[1] );
    } 
    return false;
}

function setToday() {
    start = end = new Date().toISOString().substr(0,10);
    adjustMap( null, 'today');
    return false;
}

function setLastWeek() {
    end = new Date().toISOString().substr(0,10);
    start = new Date(new Date().getTime() - (24*3600*7*1000)).toISOString().substr(0,10);
    adjustMap( null, 'lastweek');
    return false;
}

function setDays(ndays) {
    end = new Date().toISOString().substr(0,10);
    start = new Date(new Date().getTime() - (24*3600*ndays*1000)).toISOString().substr(0,10);
    adjustMap( null, 'd'+ndays );
    return false;
}

function setAll() {
    start = '2015-03-31';
    end = '2200-01-01';
    adjustMap( null, 'all' );
    return false;
}

function setMgrs() {
    start = '2014-06-13';
    end = '2014-06-14';
    adjustMap( null, 'mgrs' );
    return false;
}

function setPreChina() {
    start = '2014-01-01';
    end = '2014-06-20';
    adjustMap( null, 'china' );
    return false;
}

function setMaxStrength() {
    adjustMap( 'max', null );
    return false;
}

function setAvgStrength() {
    adjustMap( 'average', null);
    return false;
}

function setCoverage() {
    adjustMap( 'coverage', null);
    return false;
}

function setLowResCoverage() {
    adjustMap( 'lowres-coverage', null);
    return false;
}

function setSiteCount() {
    adjustMap( 'receivers', null );
    return false;
}

function setGliderCount() {
    adjustMap('gliders', null );
    return false;
}

function setSampleCount() {
    adjustMap( 'samples', null );
    return false;
}

function setLowest() {
    adjustMap( 'lowest', null);
    return false;
}

function setCompare() {
    adjustMap( 'compare', null );
    return false;
}


var nostation = { 'receivers':1, 'coverage':1 };
function adjustMap( what, when, where, colour ) {
    map.overlayMapTypes.removeAt(0);
    
    if( what ) {
	coverageOverlay.setSource( what );
	tick( 'what', what );
	if( nostation[what] ) {
	    where = '';
	}
	    
    }
    if( when ) {
	tick( 'when', when );
	coverageOverlay.setDates( start, end );
	displayStations();
    }
    if( where != null && where != undefined ) {
	where = where.toUpperCase();
	$('#typeahead').val( where );

	var latLng;
	if( stations[ where ] ) {
	    if (map.getZoom() < 9) map.setZoom(9);
	    map.setCenter( latLng = new google.maps.LatLng( stations[where].lt, stations[where].lg ) );
	}
	
	currentStation = where;
	coverageOverlay.setStation( where, latLng );
	tick( 'station', where );
    }
    if( colour != null && colour != '' ) {
	coverageOverlay.setColourScheme( colour );
	selected['colour'] = colour;
	updateURL( 'colour' );
    }

    map.overlayMapTypes.insertAt(0, coverageOverlay);
}

var hreforder = [ 'station', 'what', 'when', 'center', 'zoom', 'colour' ]; 
var updatehistory = { 'what':1, 'when':1, 'station':1 };
var titleorder = [ 'what', 'station', 'when' ];
var options = [ 'airspace', 'circles', 'ambiguity' ]; 

function tick( whattype, newItem ) {

    if( selected[whattype] && selected[whattype] !== '' && whattype !== 'station' )  {
	$('#'+selected[whattype]+' span').attr('class','');
    }
    selected[whattype] = newItem;
    if( selected[whattype] && selected[whattype] !== '' && whattype !== 'station' )  {
	$('#'+selected[whattype]+' span').attr('class','glyphicon glyphicon-ok');
    }
    
    // update the title to reflect the contents
    var title = '';
    for( var i = 0; i < titleorder.length; i++ ) {
	var v = selected[titleorder[i]];
	if( v && v != '' ) {
	    if( titleorder[i] == 'station' ) {
		title += ' - ' + v;
	    }
	    else {
		title += ' - ' + $('#'+v).text();
	    }
	}
    }
    window.document.title = 'Onglide Range' + title;
    $('#description').html( title.substr(2) );
    
    updateURL( whattype );
}


var coloursInitialised = 0;
function setColour( newColour ) {

    if( coloursInitialised++ ) {
	return;
    }

    var s = newColour.split(':');

    var start = tinycolor( s[1] ); 
    var end = tinycolor( s[0] ); 

    $("#maxc").ColorPickerSliders({
	color: start.toRgbString(),
	flat: true,
	size: 'sm',
	placement: 'left',
	customswitches: false,
	order: {
	    hsl: 1,
	    opacity: 2
	},
	onchange: function( container, colour ) {
	    if( maxTimeout ) { clearTimeout( maxTimeout ); }
	    maxTimeout = setTimeout( function() { 
		setMaxColour( colour.tiny.toHexString(), Math.round(colour.rgba.a*255) );
	    }, 500 );
	}
    }); 

    $("#minc").ColorPickerSliders({
	color: end.toRgbString(),
	flat: true,
	size: 'sm',
	placement: 'left',
	customswitches: false,
	order: {
	    hsl: 1,
	    opacity: 2
	},
	onchange: function( container, colour ) {
	    if( minTimeout ) { clearTimeout( minTimeout ); }
	    minTimeout = setTimeout( function() { 
		setMinColour( colour.tiny.toHexString(), Math.round(colour.rgba.a*255) );
	    }, 500 );
	}
    });

}

function updateURL( whattype )  {
    
    // and if we aren't processing a URL hash at the moment then update the URL
    // as well
    if( ! processingUrl ) {
	var url = '#';
	for( var i = 0; i < hreforder.length; i++, url += ',' ) {
	    if( selected[hreforder[i]] ) {
		url += selected[hreforder[i]];
	    }
	}

	for( i = 0; i < options.length; i++ ) {
	    if( selected[options[i]] ) {
		url += options[i] + ";";
	    }
	}

	// we changed it, this will stop us doing anything with it
	lasthash = url;
	if( history.pushState && updatehistory[whattype] ) { 
	    history.pushState( null, null, url );
	}
	else {
	    location.replace( url );
	}
    }
}

function readhash() {


    // make sure the hash isn't the same as we think it is this should
    // stop us parsing our own changes
    if( location.hash === lasthash ) {
	return;
    }
    lasthash = location.hash;
    processingUrl = true;
    var vals = location.hash.substr(1).split(',');

    // do options first as adjustMap will force the redraw
    if( vals[6] ) {
	var userOptions = vals[6].split(';');
	if( ~(userOptions.indexOf('airspace')) ) {
	    toggleAirspace();
	}
	if( ~(userOptions.indexOf('circles')) ) {
	    toggleCircles();
	}
	if( ~(userOptions.indexOf('ambiguity')) ) {
	    toggleAmbiguity();
	}
    }

    console.log( location.hash.substr(1) + "|%%%%|" + vals[0] );

    // Set the colour - before the adjustMap, saves a redraw
    if( vals[5] ) { 
	setColour( vals[5] );
    }
    else {
	setColour( '#00990000:#009900ff' ); // original green colouring
    }
    
    // set station, date and graph
    adjustMap( vals[1] , vals[2], vals[0] );

    // set center
    if( vals[3] ) {
	var coords = vals[3].split('_');
	if( coords.length ) {
	    map.setCenter( new google.maps.LatLng( coords[0], coords[1] ) );
	}
    }
    
    // And zoom
    if( vals[4] ) {
	map.setZoom( parseInt(vals[4]) );
    }

    processingUrl = false;
}

    
// Force a hex value to have 2 characters
function pad2(c) {
    return c.length == 1 ? '0' + c : '' + c;
}
