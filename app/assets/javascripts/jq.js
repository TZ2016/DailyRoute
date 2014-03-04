$(function() {

  // auto complete
  var availableTags = [
    "San Francisco",
    "New York",
    "Berkeley"
  ];
  $( "#newloc" ).autocomplete({
    source: availableTags
  });

  // tooltip
  // $( document ).tooltip();

  // add loc
  $( '#addloc-btn' ).click( function () {
    var address = $( "#newloc" ).val().toString();
    codeAddress(address, function (location) {
      // called after the user endered address is validated for geocoding
      var tmpelem = $( "#loc-tmp" ).clone().attr("id", "loc-temp");
      var markerid = addMarker(location);

      $( "#locs" ).append(tmpelem);
      $( "#loc-temp > .loc-tag" ).text(address);
      $( "#loc-temp" ).data("markerid", markerid);
      $( "#loc-temp" ).removeAttr("id style");
    });
  });

  // remove loc
  $( '.removeloc-btn' ).click( function () {
    $( this ).parent(".loc-entry").hide();
  });


  // sortable
  $( "#locs" ).sortable();
  $( "#locs" ).disableSelection();
});
