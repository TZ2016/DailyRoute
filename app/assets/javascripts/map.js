var geocoder;
var map;
var markers = [];

function initialize() {
  geocoder = new google.maps.Geocoder();
  var latlng = new google.maps.LatLng(-34.397, 150.644);
  var mapOptions = {
    zoom: 8,
    center: latlng
  }
  map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

  // event listerns
  // google.maps.event.addListener(map, 'click', function(event) {
  //   addMarker(event.latLng);
  // });
}

function addMarker(location, msg) {
  // return the index of the new marker
  if (msg === undefined) msg = 'marker ' + (markers.length + 1)
  map.setCenter(location);
  var marker = new google.maps.Marker({
    position: location,
    map: map,
    title: msg
  });
  markers.push(marker);
  return markers.length - 1
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

function codeAddress(address, fn) {
  // attempt to geocode address, callback fn if successful
  geocoder.geocode( { 'address': address }, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      var location = results[0].geometry.location;
      // possible extension: GeocoderResult object
      fn(location);
    } else {
      alert('Geocode was not successful for the following reason: ' + status);
    }
  });
}

google.maps.event.addDomListener(window, 'load', initialize);