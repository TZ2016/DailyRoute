// global temporary variables
var _locToRefine = [];

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
    var $locentry = $( this ).parent().parent();
    var markerid = Number($locentry.attr("id").slice(4));
    var $cnstentry = $( "#cnst-" + markerid );

    $locentry.remove();
    $cnstentry.remove();
    deleteMarker(markerid);
  });

  // add loc
  $( '#addloc-btn' ).click( function () {
    var address = $( "#newloc" ).val().toString();
    codeAddress(address, refineLocations);
  });

  // refine locations
  $( "#refineloc-lst" ).selectable();

  $( "#refineloc-none" ).click( function () {
    alertMessage("Oops! Please try with a different input.");
    $( "#refineloc-dlg" ).modal("hide");
  });

  $( "#refineloc-select" ).click( function () {
    var $selected = $( "#refineloc-lst > .ui-selected" );
    if ($selected.length === 0) {
      alertMessage("No location is yet selected!");
    } else {
      var index = $( "#refineloc-lst li" ).index($selected[0]);
      addLocation(_locToRefine[index]);
      $( "#refineloc-dlg" ).modal("hide");
    }
  });

  // time picker
  $( "#cnst-form" ).on("mousemove", ".starttime, .endtime", function() {
    $( this ).timepicker({
      'step': 30,
      'forceRoundTime': true,
      'scrollDefaultNow': true
    });
  });

  $( ".duration" ).timepicker();









function addLocation (location) {
  // add to the list of locations
  // add a constraint entry

  var address = getTagForAddress(location);
  var markerid = addMarker(location);
  var newlocid = "#loc-" + markerid;
  var newcnstid = "#cnst-" + markerid;
  var $newlocelem = $( "#loc-tmp" ).clone().attr("id", newlocid.slice(1));
  var $newcnstelem = $( "#cnst-tmp" ).clone().attr("id", newcnstid.slice(1));

  $( "#newloc" ).val("");
  $( "#locs" ).append($newlocelem);
  $( "#cnst-form" ).append($newcnstelem);
  $( newlocid + " > .loc-tag" ).text(address);
  $( newlocid ).removeAttr("style");
  $( newcnstid ).removeAttr("style"); // remove this 
}

function refineLocations (locations) {
  // called when more than one results are found

  if (locations.length === 0) {
    alertMessage("none was returned");
  } else if (locations.length == 1) {
    addLocation(locations[0]);
  } else {
    // refineloc-lst refineloc-lst-tmp refineloc-dlg
    _locToRefine = [];
    $( "#refineloc-lst" ).empty();
    
    locations.forEach(function (location) {
      var name = getNameOfAddress(location);
      var $temp = $( "#refineloc-lst-tmp" ).clone().removeAttr("id");

      _locToRefine.push(location);
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
