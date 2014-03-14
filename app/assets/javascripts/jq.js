// data returned from the back end
var _result = {};

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

  // add loc
  $('#newloc').bind('keypress', function(e) {
    if(e.keyCode==13){
      $.handleAddLocation();
    }
  });

  $( '#addloc-btn' ).click( $.handleAddLocation );

  // dropdown
  $( "#addloc-dp-clear" ).click( function() {
    $( "#newloc" ).val("");
  });

  // remove loc
  $( '#loc-acc' ).on("click", ".remove-btn", function () {
    var $accentry = $( this ).parent().parent().parent().parent().parent().parent(); //ERRORPRONE
    var markerid = Number($accentry.attr("id").split("-").pop());

    $accentry.remove();
    deleteMarker(markerid);
  });

  // accordion main
  $( "#loc-acc" )
    .accordion({
      header: "> div > h3",
      collapsible: true
    })
    .sortable({
      axis: "y",
      handle: "h3",
      stop: function( event, ui ) {
        // IE doesn't register the blur when sorting
        // so trigger focusout handlers to remove .ui-state-focus
        ui.item.children( "h3" ).triggerHandler( "focusout" );
      }
  });

  // accordion instruction
  $( "#loc-acc-ins" ).accordion({
    header: "> div > h3",
    collapsible: true
  });

  // direction panel
  $( "#dir-panel-temp" ).accordion();
  $( "#dir-panel" ).accordion({
    collapsible: true,
    active: false,
    heightStyle: 'content',
    beforeActivate: $.displayRoute
  });

  // refine location dialog
  $( "#refineloc-lst" ).selectable();

  $( "#refineloc-none" ).click( function () {
    $.alertMessage("Oops! Please try with a different input.");
    $( "#refineloc-dlg" ).modal("hide");
  });

  $( "#refineloc-select" ).click( function () {
    var $selected = $( "#refineloc-lst > .ui-selected" );
    if ($selected.length === 0) {
      $.alertMessage("No location is yet selected!");
    } else {
      var index = $( "#refineloc-lst li" ).index($selected[0]);
      $.addLocation(_locToRefine[index]);
      $( "#refineloc-dlg" ).modal("hide");
    }
  });

  // time picker
  $( "#loc-acc" ).on("mousemove", ".time-start-A, .time-start-B, .time-end-A, .time-end-B", function() {
    $( this ).timepicker({
      'step': 30,
      'forceRoundTime': true,
      'scrollDefaultNow': true
    });
  });

  // test calc route
  $( "#testcalc" ).click( function() {
    //FIXME
    // send request to back end and store to _result variable    
    geocoder.geocode( { 'address': "Berkeley" }, function(res, s) {
      var result = res[0].geometry.location;
      var result2 = res[1].geometry.location;
      var loc1 = {'Lat': result.lat(), 'Long': result.lng()};
      var loc2 = {'Lat': result2.lat(), 'Long': result2.lng()};
      _data = { 'errCode': 1, 'route': [loc1, loc2, loc1, loc2] };
    });

  });

});






jQuery.handleAddLocation = function () {
  var address = $( "#newloc" ).val().toString();
  $( "#loc-acc-ins" ).attr("style", "display: none;");
  codeAddress(address, $.refineLocations);
};

jQuery.addLocation = function (location) {
  // add to the list of locations
  // add a constraint entry

  var address = getTagForAddress(location);
  var markerid = addMarker(location);
  var newlocid = "#loc-acc-" + markerid;
  var $newlocelem = $( "#loc-acc-tmp" ).clone().attr("id", newlocid.slice(1));

  $( "#newloc" ).val("");

  $( "#loc-acc" ).append($newlocelem);
  $( newlocid + " > h3" ).text(address);
  $( newlocid ).removeAttr("style");
  $( "#loc-acc" ).accordion("refresh");
  $( "#loc-acc" ).accordion({ active: markerid+1 });
};

jQuery.refineLocations = function (locations) {
  // called when more than one results are found

  if (locations.length === 0) {
    $.alertMessage("none was returned");
  } else if (locations.length == 1) {
    $.addLocation(locations[0]);
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
};

jQuery.displayRoute = function (ev, ui) {
  var num = 1; // FIXME
  var pid = "route-" + num;

  $( "#" + pid + "> h3" ).text("Route " + num);
  drawRoute(_data['route'], pid);
};

jQuery.alertMessage = function (msg) {
  alert(msg);
};
