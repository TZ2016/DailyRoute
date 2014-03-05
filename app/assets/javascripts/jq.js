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

  // sortable
  $( "#locs" ).sortable();
  $( "#locs" ).disableSelection();

  // remove loc
  $( '#locs' ).on("click", ".removeloc-btn", function () {
    var $entry = $( this ).parent().parent();
    var markerid = Number($entry.attr("id").slice(4));

    console.log($entry.attr("id"));
    console.log(markerid);
    $entry.remove();
    deleteMarker(markerid);
  });

  // add loc
  $( '#addloc-btn' ).click( function () {
    var address = $( "#newloc" ).val().toString();
    codeAddress(address, refineLocations);
  });

  // refine locations
  $( "#refineloc-lst" ).selectable();
  

function addLocation (location) {
  // add to the list of locations

  var address = getTagForAddress(location);
  var markerid = addMarker(location);
  var newid = "#loc-" + markerid;
  var $newelem = $( "#loc-tmp" ).clone().attr("id", newid.slice(1));

  $( "#locs" ).append($newelem);
  $( newid + " > .loc-tag" ).text(address);
  $( newid ).removeAttr("style");
}

function refineLocations (locations) {
  // called when more than one results are found

  if (locations.length === 0) {
    alertMessage("none was returned");
  } else if (locations.length == 1) {
    addLocation(locations[0]);
  } else {
    // refineloc-lst refineloc-lst-tmp refineloc-dlg
    var $temp = $( "#refineloc-lst-tmp" ).clone().removeAttr("id");
    $( "#refineloc-lst" ).empty();
    locations.forEach(function (location) {
      var name = getNameOfAddress(location);
      $( "#refineloc-lst" ).append( $temp.clone().text(name));
    });
    $( "#refineloc-dlg" ).modal({
      show: true,
      keyboard: false,
      backdrop: "static"
    });
  }
}

function alertMessage (msg) {
  alert(msg);
}

});
