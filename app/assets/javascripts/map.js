var geocoder;
var map;
var markers = [];

function initialize() {
  geocoder = new google.maps.Geocoder();
  var latlng = new google.maps.LatLng(-34.397, 150.644);
  var mapOptions = {
    zoom: 8,
    center: latlng
  };
  map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

  // event listerns
  // google.maps.event.addListener(map, 'click', function(event) {
  //   addMarker(event.latLng);
  // });
}

function addMarker(location, msg) {
  // return the index of the new marker
  if (msg === undefined) msg = 'marker ' + (markers.length + 1);
  map.setCenter(location);
  var marker = new google.maps.Marker({
    position: location,
    map: map,
    title: msg
  });
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
      alert('Geocode was not successful for the following reason: ' + status);
    }
  });
}

// helpers

function getTagForAddress(geores) {
  return geores.address_components[0].short_name;
}

function getNameOfAddress(geores) {
  // return the full name of the address backed by GeocoderResult object
  var components = [];
  geores.address_components.forEach(function (addrcomp) {
    components.push(addrcomp.short_name);
  });
  return components.join(", ");
}

google.maps.event.addDomListener(window, 'load', initialize);