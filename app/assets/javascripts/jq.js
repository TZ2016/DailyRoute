// data communication
var _url_calcroute = "newroute";
var _url_login = "signin";
var _url_logout = "signout";
var _url_signup = "signup";
var _url_saved = "routes";
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

$(function () {
  initPage();
});
$(window).bind('page:change', function () {
  initPage();
});
function initPage () {

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

  // mode
  $( "#trans-mode" ).buttonset();

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
  $( "#dir-ins" ).accordion({
    heightStyle: "content"
  });
  $( "#dir-acc" ).accordion({
    header: "> div > h3",
    collapsible: true,
    active: false,
    heightStyle: 'content',
    beforeActivate: $.displayRoute
  });

  // saved routes panel
  $( "#savedroutes-ins" ).accordion({
    heightStyle: "content"
  });
  $( "#savedroutes-acc" ).accordion({
    header: "> div > h3",
    collapsible: true,
    active: false,
    heightStyle: 'content'
  });
    // beforeActivate: $.displayRoute

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

  // view result button and utilities
  $( "#calc-btn" ).click( function () {
    // $( "#dir-acc" ).attr("style", "display: none;");
    $( "#dir-acc" ).accordion( "option", "active", false );

    genSendData();
    $.sendQuery();
  });

  /////////////////////////////////////////////////////////

  $( "#signin-form #signup" ).click( function () {
    $( "#signup-dlg" ).modal({
      show: true,
      keyboard: false,
      backdrop: "static"
    });
  });

  $( "#signup-cancel" ).click( function () {
    $( "#signup-dlg" ).modal("hide");
  });

  $( "#signup-btn" ).click( function () {
    credentials = {'email':    $( "#signup-email" ).val().toString(),
                 'password': $( "#signup-pw" ).val().toString(),
                 'password_confirmation': $( "#signup-pwcf" ).val().toString()
                };
    $.ajax({
      type: 'POST',
      url:  _url_signup,
      data: JSON.stringify(credentials),
      contentType: "application/json",
      dataType: "json",
      beforeSend: function (jqXHR, settings) {
      },
      success: function (data, status, jqXHR) {
        errCode = data['errCode'];
        if (errCode == 1) {
          location.reload();
        } else {
          var i = 1;
          var msg = "Your credentials were rejected due to: \n";
          data['reasons'].forEach( function (r) {
            msg += i + ". " + r.toString() + "\n";
            i += 1;
          });
          $.alertMessage(msg);
        }
      },
      error: function (jqXHR, status, error) {
        $.alertMessage("Server Error!");
      }
    });
  });

  $( "#signin-form #signin" ).click( function () {
    credentials = {'email':    $( "#email-field" ).val().toString(),
                   'password': $( "#password-field" ).val().toString()
                  };
    $.ajax({
      type: 'POST',
      url:  _url_login,
      data: JSON.stringify(credentials),
      contentType: "application/json",
      dataType: "json",
      beforeSend: function (jqXHR, settings) {
      },
      success: function (data, status, jqXHR) {
        errCode = data['errCode'];
        if (errCode == 1) {
          location.reload();
        } else {
          $.alertMessage("Invalid combination!");
        }
      },
      error: function (jqXHR, status, error) {
        $.alertMessage("Server Error!");
      }
    });
  });

  $( "#logout-btn" ).click( function () {
    $.ajax({
      type: 'DELETE',
      url:  _url_logout,
      beforeSend: function (jqXHR, settings) {
      },
      success: function (data, status, jqXHR) {
        location.reload();
      },
      error: function (jqXHR, status, error) {
        $.alertMessage("Server Error!");
      }
    });
  });

  // $( "#routes-btn" ).click( function () {
  //   $( "#sidebar-main" ).hide();
  //   $( "#sidebar-saved" ).show();

  //   //FIXME
  //   $.ajax({
  //     type: 'GET',
  //     url:  _url_saved,
  //     contentType: "application/json",
  //     dataType: "json",
  //     beforeSend: function (jqXHR, settings) {
  //     },
  //     success: function (data, status, jqXHR) {
  //       // data = {errCode: , route: []}
  //       handleResult(data, "savedroutes", "savedroutes-acc");
  //     },
  //     error: function (jqXHR, status, error) {
  //     }
  //     });
  // });

  $( "#return-btn" ).click( function () {
    $( "#sidebar-main" ).show();
    $( "#sidebar-saved" ).hide();
  });

}

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
    url:  _url_calcroute,
    data: JSON.stringify(_sendData),
    contentType: "application/json",
    dataType: "json",
    beforeSend: function (jqXHR, settings) {
      $( "#dir-row" ).removeAttr("style");
      $( "#dir-ins > h3" ).text("Calculating...");
      $( "#dir-ins > div" ).text("Your query data was sent.");
    },
    success: function (data, status, jqXHR) {
      $( "#dir-ins > h3" ).text("Instruction");
      $( "#dir-ins > div" ).text("Your routes are ready.");
      handleResult(data, "route", "dir-acc");
    },
    error: function (jqXHR, status, error) {
      $( "#dir-row" ).attr("style", "display: none;");
      $.alertMessage("Your query failed.");
    }
  });
};

function handleResult (data, baseID, accID) {
  console.log(data);
  if (data["errCode"] == 1) {
    _data = data;
    var index = 0;
    var $temppanel = $( "#"+baseID+"-temp" ).clone().removeAttr("style");
    
    $( "#"+accID ).empty();
    $( "#"+accID ).append( $temppanel.clone().attr("style", "display:none;") );

    _data['routes'].forEach( function (route) {
      index += 1;
      var newid = baseID + "-" + index;
      var $newpanel = $temppanel.clone().attr("id", newid);

      $( "#"+accID ).append( $newpanel );
      $( "#"+newid+" > .route-title" ).text("Route " + index).attr("id", newid+"-title");
      $( "#"+newid+" > .route-content" ).attr("id", newid+"-content");
    });
    $( "#"+accID ).accordion("refresh");
  } else {
    _data = [];
    $.alertMessage("Google server denied your request!(code="+data['errCode']+")");
  }
}

function genSendData () {
  // _sendData
  var $locs = $( "#loc-acc" ).children();
  var entry;
  var _dataToSend = {};

  _dataToSend['locationList'] = [];
  switch($('#trans-mode :checked').attr("id")) {
    case "mode-d":
      _dataToSend['travelMethod'] = "driving";
      break;
    case "mode-w":
      _dataToSend['travelMethod'] = "walking";
      break;
    case "mode-b":
      _dataToSend['travelMethod'] = "bycycling";
      break;
    case "mode-t":
      _dataToSend['travelMethod'] = "transit";
      break;
  }

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
    _dataToSend['locationList'].push(entry);
  }
  _sendData["route"] = _dataToSend;
}

jQuery.displayRoute = function (ev, ui) {
  if (ui.newHeader.text() !== "") {
    var num = Number(ui.newHeader.text().split(" ").pop());
    var baseID = ui.newHeader.parent().attr("id").split("-")[0];
    var pid = baseID + "-" + num + "-content";

    drawRoute(num, pid);
  }
};

// utilities

jQuery.alertMessage = function (msg) {
  alert(msg);
};
