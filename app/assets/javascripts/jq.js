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
      var markerid = addMarker(location);
      var newid = "#loc-" + markerid
      var $newelem = $( "#loc-tmp" ).clone().attr("id", newid.slice(1));

      $( "#locs" ).append($newelem);
      $( newid + " > .loc-tag" ).text(address);
      $( newid ).removeAttr("style");
    });
  });

  // remove loc
  $( '#locs' ).on("click", ".removeloc-btn", function () {
    var $entry = $( this ).parent().parent();
    var markerid = Number($entry.attr("id").slice(4));

    console.log($entry.attr("id"));
    console.log(markerid);
    $entry.remove();
    deleteMarker(markerid);
  });

  // sortable
  $( "#locs" ).sortable();
  $( "#locs" ).disableSelection();
});
