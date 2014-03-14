// data communication
var _url = "/main/parseRoute";
var _sendGeo = [];
var _result = {};
var _sendData = {'travelMethod': undefined,
                 'locationList':
                   [{ 'searchtext': undefined,
                      'geocode': ('lat', 'lng'),
                      'minduration': undefined,
                      'maxduration': undefined,
                      'arrivebefore': undefined,
                      'arriveafter': undefined,
                      'departbefore': undefined,
                      'departafter': undefined,
                      'priority': undefined
                    }]
             };

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
    $.removeLocation(this);
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
    heightStyle: 'content',
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

  // view result button and utilities

  $( "#calc-btn" ).click( function () {
    genSendData();
    $.sendQuery();
  });

  $( document ).ajaxComplete(function( event, request, settings ) {
    if (settings.url === _url) {
      $( "#dir-panel-temp > h3" ).text("Calculating...");
      $( "#dir-panel-temp > div" ).text("Your query data was send.");
    }
  });

  $( document ).ajaxSuccess(function( event, request, settings ) {
    if (settings.url === _url) {
      $( "#dir-panel-temp > h3" ).text("Instruction");
      $( "#dir-panel-temp > div" ).text("Your routes are ready.");
    }
  });

});



// Adding location

jQuery.addLocation = function (location) {
  // add to the list of locations
  // add a constraint entry

  var address = getTagForAddress(location);
  var markerid = addMarker(location);
  var newlocid = "#loc-acc-" + markerid;
  var $newlocelem = $( "#loc-acc-tmp" ).clone().attr("id", newlocid.slice(1));

  _sendGeo[markerid] = location;

  $( "#newloc" ).val("");
  $( "#loc-acc" ).append($newlocelem);
  $( newlocid + " > h3" ).text(address);
  $( newlocid ).removeAttr("style");
  $( "#loc-acc" ).accordion("refresh");
  $( "#loc-acc" ).accordion({ active: markerid+1 });
};

jQuery.handleAddLocation = function () {
  var address = $( "#newloc" ).val().toString();
  $( "#loc-acc-ins" ).attr("style", "display: none;");
  codeAddress(address, $.refineLocations);
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

jQuery.removeLocation = function (rmvobj) {
    var $accentry = $( rmvobj ).parent().parent().parent().parent().parent().parent(); //ERRORPRONE
    var markerid = Number($accentry.attr("id").split("-").pop());

    $accentry.remove();
    deleteMarker(markerid);
    delete _sendGeo[markerid];

    if ($("#loc-acc > div").length == 1) {
      $( "#loc-acc-ins" ).removeAttr("style");
    }
};

// view result

jQuery.sendQuery = function () {
  $.ajax({
    type: 'POST',
    url:  _url,
    data: JSON.stringify(_sendData),
    contentType: "application/json",
    dataType: "json"
  });
};

function genSendData () {
  // _sendData
  var $locs = $( "#loc-acc" ).children();
  var entry;

  _sendData['travelMethod'] = "driving";
  _sendData['locationList'] = [];

  for (var i = 1; i < $locs.length; i++) {

    var $loc = $($locs[i]);
    var entryid = $loc.attr('id');
    var id = Number(entryid.split("-").pop());
    var coord = _sendGeo[id].geometry.location;

    entry = {};
    entry['geocode'] = {'lat': coord.lat(), 'lng': coord.lng()};
    entry['searchtext'] = getTagForAddress(_sendGeo[id]);
    entry['minduration'] = $( "#"+entryid+" .dur-A" ).val().toString();
    entry['maxduration'] = $( "#"+entryid+" .dur-B" ).val().toString();
    entry['arriveafter'] = $( "#"+entryid+" .time-start-A" ).val().toString();
    entry['arrivebefore'] = $( "#"+entryid+" .time-start-B" ).val().toString();
    entry['departafter'] = $( "#"+entryid+" .time-end-A" ).val().toString();
    entry['departbefore'] = $( "#"+entryid+" .time-end-B" ).val().toString();
    entry['priority'] = 0;
    _sendData['locationList'].push(entry);
  }
}

jQuery.displayRoute = function (ev, ui) {
  var num = 1; // FIXME
  var pid = "route-" + num;

  $( "#" + pid + "> h3" ).text("Route " + num);
  drawRoute(_data['route'], pid);
};

// utilities

jQuery.alertMessage = function (msg) {
  alert(msg);
};
