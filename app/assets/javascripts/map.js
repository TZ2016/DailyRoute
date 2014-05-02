var geocoder;
var map;
var rendererOptions = {
  // draggable: true
  draggable: false
};
var directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
var directionsService = new google.maps.DirectionsService();
var markers = [];
var _tempmarker;
var infowindow = new google.maps.InfoWindow();
var markerListener = null;

function initialize() {
  geocoder = new google.maps.Geocoder();
  var latlng = new google.maps.LatLng(-34.397, 150.644);
  var mapOptions = {
    zoom: 8,
    center: latlng
  };
  map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
  directionsDisplay.setMap(map);

}

function dropMarkerSwitch(s) {
  // listeners
  if (s === true && markerListener === null) {
      markerListener = google.maps.event.addListener(map, 'click', function(e) {
        revGeoAndMarker(e.latLng);
    });
  }
  if (s === false && markerListener !== null) {
    google.maps.event.removeListener(markerListener);
    markerListener = null;
  }
}

function addMarker(loc, msg) {
  // return the index of the new marker
  if (msg === undefined) msg = 'marker ' + (markers.length + 1);
  var marker;
  if (loc !== null) {
    var location = loc.geometry.location;
    map.setCenter(location);
    marker = new google.maps.Marker({
      position: location,
      map: map,
      title: msg
    });
    infowindow.setContent(loc.formatted_address);
    infowindow.open(map, marker);
  } else {
    marker = null; // smoke
  }
  markers.push(marker);
  return markers.length - 1;
}

function hideMarkers() {
  markers.forEach(function(marker) {
    if (marker !== null) {
      marker.setMap(null);
    }
  });
}

function deleteMarker(index) {
  // delete the marker at index
  if (index in markers) {
    markers[index].setMap(null);
    delete markers[index];
    return true;
  } else {
    return false;
  }
}

function codeAddress(address, refineLocations) {
  // attempt to geocode address, callback refineLocations if not abnormal error
  geocoder.geocode( { 'address': address }, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      refineLocations(results);
    } else if (status == google.maps.GeocoderStatus.ZERO_RESULTS) {
      refineLocations([]);
    } else{
      $.alertMessage('Geocode was not successful for the following reason: ' + status);
    }
  });
}


function getTagForAddress(geores) {
  return geores.address_components[0].long_name;
}

function getNameOfAddress(geores) {
  return geores.formatted_address;
}

function drawRoute(num, panelid) {
  hideMarkers();
    directionsDisplay.setPanel(document.getElementById(panelid));

  var data = _data['routes'][num-1];
  var size = data["steps"].length;
  var start = new google.maps.LatLng(
    parGeoLat(data["steps"][0]["geocode"]), parGeoLng(data["steps"][0]["geocode"]));
  var end = new google.maps.LatLng(
    parGeoLat(data["steps"][size-1]["geocode"]), parGeoLng(data["steps"][size-1]["geocode"]));
  var selectedMode = data['mode'].toUpperCase();
  var waypts = [];
  var loc;
  for (var i = 1; i < size-1; i++) {
    loc = new google.maps.LatLng(
      parGeoLat(data["steps"][i]["geocode"]), parGeoLng(data["steps"][i]["geocode"]));
    waypts.push({
        location: loc,
        stopover: true
    });
  }
  var request = {
    origin:start,
    destination:end,
    travelMode: google.maps.TravelMode[selectedMode],
    optimizeWaypoints: false,
    waypoints: waypts
  };

  directionsService.route(request, function(response, status) {
    if (status == google.maps.DirectionsStatus.OK) {
      directionsDisplay.setDirections(response);
    }
  });

}

function parGeoLat(geocode){
  return geocode.split(",")[0];
}

function parGeoLng(geocode){
  return geocode.split(",")[1];
}


function revGeoAndMarker(latlng) {
  geocoder.geocode({'latLng': latlng}, function (results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      if (results[1]) {
        revGeoAndMarkerHelper(results[1]);
      } else {
        $.alertMessage('No results found');
      }
    } else {
      $.alertMessage('Geocoder failed due to: ' + status);
    }
  });
}

function revGeoAndMarkerHelper(geocoderres) {
  // geocoderres is a GeoCoderResult Object
  if (_tempmarker !== undefined) {
    _tempmarker.setMap(null);
  }

  var location = geocoderres.geometry.location;
  var fulladdr = getNameOfAddress(geocoderres);
  var marker = new google.maps.Marker({
    position: location,
    map: map
  });
  infowindow.setContent(fulladdr);
  infowindow.open(map, marker);
  _tempmarker = marker;

  // FIXME
  document.getElementById("newloc").value = fulladdr;
}

google.maps.event.addDomListener(window, 'load', initialize);