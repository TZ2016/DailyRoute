var geocoder;
var map;
var rendererOptions = {
  draggable: true
};
var directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
var directionsService = new google.maps.DirectionsService();
var markers = [];
var _tempmarker;
var marker_geo;
var infowindow = new google.maps.InfoWindow();

function initialize() {
  geocoder = new google.maps.Geocoder();
  var latlng = new google.maps.LatLng(-34.397, 150.644);
  var mapOptions = {
    zoom: 8,
    center: latlng
  };
  map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
  directionsDisplay.setMap(map);
  directionsDisplay.setPanel(document.getElementById("directionsPanel"));

  // listeners
  google.maps.event.addListener(map, 'click', function(e) {
    console.log(e);
    revGeoAndMarker(e.latLng);
  });

}

function addMarker(loc, msg) {
  // return the index of the new marker
  if (msg === undefined) msg = 'marker ' + (markers.length + 1);
  var location = loc.geometry.location;
  map.setCenter(location);
  var marker = new google.maps.Marker({
    position: location,
    map: map,
    title: msg
  });
  infowindow.setContent(loc.formatted_address);
  infowindow.open(map, marker);
  markers.push(marker);
  return markers.length - 1;
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
      alertMessage('Geocode was not successful for the following reason: ' + status);
    }
  });
}


function getTagForAddress(geores) {
  return geores.address_components[0].long_name;
}

function getNameOfAddress(geores) {
  return geores.formatted_address;
}

// function getNameOfAddress(geores) {
//   // return the full name of the address backed by GeocoderResult object
//   var components = [];
//   geores.address_components.forEach(function (addrcomp) {
//     components.push(addrcomp.short_name);
//   });
//   return components.join(", ");
// }





function calcRoute(data) {
  var size = data.length;
  var start = new google.maps.LatLng(data[0].Lat, data[0].Long);
  var end = new google.maps.LatLng(data[size-1].Lat, data[size-1].Long);
  // var selectedMode = document.getElementById("mode").value;
  var selectedMode = "DRIVING";
  var waypts = [];
  var loc;
  for (var i = 1; i < size-1; i++) {
    loc = new google.maps.LatLng(data[i].Lat, data[i].Long);
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
      var route = response.routes[0];
      var summaryPanel = document.getElementById("directions_panel");
      summaryPanel.innerHTML = "";
      // For each route, display summary information.
      for (var i = 0; i < route.legs.length; i++) {
        var routeSegment = i+1;
        summaryPanel.innerHTML += "<b>Route Segment: " + routeSegment + "</b><br />";
        summaryPanel.innerHTML += route.legs[i].start_address + " to ";
        summaryPanel.innerHTML += route.legs[i].end_address + "<br />";
        summaryPanel.innerHTML += route.legs[i].distance.text + "<br /><br />";
      }
    }
  });

  google.maps.event.addListener(directionsDisplay, 'directions_changed', function() {
      computeTotalDistance(directionsDisplay.directions);
  });
}


function computeTotalDistance(result) {
  var total = 0;
  var myroute = result.routes[0];
  for (i = 0; i < myroute.legs.length; i++) {
    total += myroute.legs[i].distance.value;
  }
  total = total / 1000.0;
  document.getElementById("total").innerHTML = total + " km";
}

// function convertToLatLng(input) {
//   var latlngStr = input.split(',', 2);
//   var lat = parseFloat(latlngStr[0]);
//   var lng = parseFloat(latlngStr[1]);
//   var latlng = new google.maps.LatLng(lat, lng);
//   return latlng;
// }

function revGeoAndMarker(latlng) {
  geocoder.geocode({'latLng': latlng}, function (results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      if (results[1]) {
        revGeoAndMarkerHelper(results[1]);
      } else {
        alertMessage('No results found');
      }
    } else {
      alertMessage('Geocoder failed due to: ' + status);
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
  var shortname = getTagForAddress(geocoderres);
  map.setCenter(location);
  var marker = new google.maps.Marker({
    position: location,
    map: map
  });
  infowindow.setContent(fulladdr);
  infowindow.open(map, marker);
  _tempmarker = marker;

  // FIXME
  document.getElementById("newloc").value = shortname;
}

google.maps.event.addDomListener(window, 'load', initialize);