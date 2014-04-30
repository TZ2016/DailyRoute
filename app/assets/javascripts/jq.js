// data communication
var _url_calcroute = "newroute";
var _url_signup = "signup_post";
var _sendGeo = [];
var _sendData = {};

// global temporary variables
var _locToRefine = [];

$(function () {
  initPage();
});
$(window).bind('page:change', function () {
  initPage();
});
function initPage() {

  // auto complete
  var availableTags = [
    "San Francisco",
    "New York",
    "Berkeley"
  ];
  $("#newloc").autocomplete({
    source: availableTags
  });

  // add loc
  $('#newloc').bind('keypress', function (e) {
    if (e.keyCode == 13) {
      $.handleAddLocation();
    }
  });

  $('#addloc-btn').click($.handleAddLocation);

  // dropdown
  $("#addloc-dp-clear").click(function () {
    $("#newloc").val("");
  });

  // fuzzy add
  $("#fuzzy-btn").click($.handleFuzzyAdd);

  // mode
  $("#trans-mode").buttonset();

  // remove loc
  $('#loc-acc')
      .on("click", ".remove-btn", function () {
        $.removeLocation(this);
      })
      .accordion({
        header: "> div > h3",
        collapsible: true
      })
      .sortable({
        axis: "y",
        handle: "h3",
        stop: function (event, ui) {
          // IE doesn't register the blur when sorting
          // so trigger focusout handlers to remove .ui-state-focus
          ui.item.children("h3").triggerHandler("focusout");
        }
      });

  // accordion instruction
  $("#loc-acc-ins").accordion({
    header: "> div > h3",
    heightStyle: 'content',
    collapsible: true
  });

  // direction panel
  $("#dir-ins").accordion({
    heightStyle: "content"
  });
  $("#dir-acc").accordion({
    header: "> div > h3",
    collapsible: true,
    active: false,
    heightStyle: 'content',
    beforeActivate: $.displayRoute
  });

  // saved routes panel
  $("#savedroutes-ins").accordion({
    heightStyle: "content"
  });
  $("#savedroutes-acc").accordion({
    header: "> div > h3",
    collapsible: true,
    active: false,
    heightStyle: 'content'
  });

  // refine location dialog
  $("#refineloc-lst").selectable();

  $("#refineloc-none").click(function () {
    $.alertMessage("Oops! Please try with a different input.");
    $("#refineloc-dlg").modal("hide");
  });

  $("#refineloc-select").click(function () {
    var $selected = $("#refineloc-lst > .ui-selected");
    if ($selected.length === 0) {
      $.alertMessage("No location is yet selected!");
    } else {
      var index = $("#refineloc-lst li").index($selected[0]);
      $.addLocation(_locToRefine[index]);
      $("#refineloc-dlg").modal("hide");
    }
  });

  // time picker
  $("#loc-acc").on("mousemove", ".time-start-A, .time-start-B, .time-end-A, .time-end-B", function () {
    $(this).timepicker({
      'step': 15,
      'forceRoundTime': true,
      'scrollDefaultNow': true
    });
  });

  // view result button and utilities
  $("#calc-btn").click(function () {
    // $( "#dir-acc" ).attr("style", "display: none;");
    $("#dir-acc").accordion("option", "active", false);

    genSendData();
    $.sendQuery();
  });

  // rails ajax button
  $('#calc-btn2')
      .bind("ajax:before", function (evt, xhr, settings) {
        $("#dir-acc").accordion("option", "active", false);
        $("#dir-row").removeAttr("style");
        $("#dir-ins > h3").text("Calculating...");
        $("#dir-ins > div").text("Your query data was sent.");
        genSendData();
        $(this).data('params', JSON.stringify(_sendData));
        console.log(_sendData);
      })
      .bind("ajax:beforeSend", function (ent, xhr, settings) {
        xhr.setRequestHeader('content-type', 'application/json');
      })
      .bind("ajax:error", function (jqXHR, status, error) {
        $("#dir-row").attr("style", "display: none;");
        $.alertMessage("Your query failed.");
        console.log(status);
        console.log(error);
      });

  // group location
  $('.multi-field-wrapper').each(function () {
    var $wrapper = $('.multi-fields', this);
    $(".add-field", $(this)).click(function (e) {
      var $toadd = $('.multi-field:first-child', $wrapper).clone(true).removeAttr("style");
      var $lst = $toadd.find(".loc-group").empty();

      markers.map(function (_, i) {
        if (i > 0 && i < markers.length - 1) {
          var newlocid = "#loc-acc-" + i + " > h3";
          var title = $(newlocid).text();
          var opt = "<option>" + title + "</option>";
          $(opt).prependTo($lst);
        }
      });
      $toadd.appendTo($wrapper);
    });
    $('.multi-field .remove-field', $wrapper).click(function () {
      if ($('.multi-field', $wrapper).length > 1)
        $(this).parent('.multi-field').remove();
    });
  });

  /////////////////////////////////////////////////////////

  $("#signup").click(function () {
    $("#signup-dlg").modal({
      show: true,
      keyboard: false,
      backdrop: "static"
    });
  });

  $("#signup-cancel").click(function () {
    $("#signup-dlg").modal("hide");
  });

  $("#signup-btn").click(function () {
    credentials = {'user': {'email': $("#signup-email").val().toString(),
      'password': $("#signup-pw").val().toString(),
      'password_confirmation': $("#signup-pwcf").val().toString()
    }};
    $.ajax({
      type: 'POST',
      url: _url_signup,
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
          data['reasons'].forEach(function (r) {
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

}

// Adding location

jQuery.addLocation = function (location, tag) {
  // add to the list of locations
  // add a constraint entry

  var address;
  if (typeof location === 'string') {
    // address = typeof tag !== 'undefined' ? tag : 'Unnamed Fuzzy Add Category';
    address = location;
    location = null;
  } else {
    address = getTagForAddress(location);
  }

  var markerid = addMarker(location, address);
  var newlocid = "#loc-acc-" + markerid;
  var $newlocelem = $("#loc-acc-tmp").clone().attr("id", newlocid.slice(1));

  _sendGeo[markerid] = location;

  $("#newloc").val("");
  $("#loc-acc").append($newlocelem);
  $(newlocid + " > h3").text(address);
  $(newlocid).removeAttr("style");
  $("#loc-acc").accordion("refresh");
  $("#loc-acc").accordion({ active: markerid + 1 });
};

jQuery.handleAddLocation = function () {
  var address = $("#newloc").val().toString();
  $("#loc-acc-ins").attr("style", "display: none;");
  codeAddress(address, $.refineLocations);
};

jQuery.handleFuzzyAdd = function () {
  var address = $("#newloc").val().toString();
  $("#loc-acc-ins").attr("style", "display: none;");
  $.addLocation(address);
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
    $("#refineloc-lst").empty();

    locations.forEach(function (location) {
      var name = getNameOfAddress(location);
      var $temp = $("#refineloc-lst-tmp").clone().removeAttr("id");

      _locToRefine.push(location);
      $("#refineloc-lst").append($temp.clone().text(name));
    });

    $("#refineloc-dlg").modal({
      show: true,
      keyboard: false,
      backdrop: "static"
    });

  }
};

jQuery.removeLocation = function (rmvobj) {
  var $accentry = $(rmvobj).parent().parent().parent().parent().parent().parent(); //ERRORPRONE
  var markerid = Number($accentry.attr("id").split("-").pop());

  $accentry.remove();
  deleteMarker(markerid);
  delete _sendGeo[markerid];

  if ($("#loc-acc > div").length == 1) {
    $("#loc-acc-ins").removeAttr("style");
  }
};

// view result

jQuery.sendQuery = function () {
  $.ajax({
    type: 'POST',
    url: _url_calcroute,
    data: JSON.stringify(_sendData),
    contentType: "application/json",
    dataType: "json",
    beforeSend: function (jqXHR, settings) {
      $("#dir-row").removeAttr("style");
      $("#dir-ins > h3").text("Calculating...");
      $("#dir-ins > div").text("Your query data was sent.");
    },
    success: function (data, status, jqXHR) {
      $("#dir-ins > h3").text("Instruction");
      $("#dir-ins > div").text("Your routes are ready.");
      handleResult(data, "route", "dir-acc");
    },
    error: function (jqXHR, status, error) {
      $("#dir-row").attr("style", "display: none;");
      $.alertMessage("Your query failed.");
    }
  });
};

function formatTime(seconds) {
  var s = seconds % 60;
  var minutes = Math.floor(seconds / 60);
  var m = minutes % 60;
  var hours = Math.floor(minutes / 60);
  var h = hours % 60;
  var d = Math.floor(hours / 24);

  if (d !== 0) {
    return d+' d '+h+' h ';
  }
  if (h !== 0) {
    return h+' h '+m+' m ';
  }
  if (m !== 0) {
    return m+' m '+s+' s ';
  }
  return s+' s ';
}

function handleResult(data, baseID, accID) {
  if (data["errCode"] == 1) {
    _data = data;
    var index = 0;
    var $temppanel = $("#" + baseID + "-temp").clone().removeAttr("style");

    $("#" + accID).empty();
    $("#" + accID).append($temppanel.clone().attr("style", "display:none;"));

    _data['routes'].forEach(function (route) {
      index += 1;
      var newid = baseID + "-" + index;
      var $newpanel = $temppanel.clone().attr("id", newid);
      var notice = '';

      notice += '';
      notice += '<strong>Travel Time</strong>: ' + formatTime(route['traveltime']) + "<br>";
      notice += '<strong>Route itinerary</strong>: <br>';

      $("#" + accID).append($newpanel);
      $("#" + newid + " > .route-title").text("Route " + index).attr("id", newid + "-title");
      $("#" + newid + " > .route-content").attr("id", newid + "-content").html(notice);
    });
    $("#" + accID).accordion("refresh");
  } else {
    _data = [];
    $.alertMessage("Google server denied your request!(code=" + data['errCode'] + ")");
  }
}

function genSendData() {
  // _sendData
  var $locs = $("#loc-acc").children();
  var entry;
  var _dataToSend = {};

  // group
  _dataToSend['groups'] = [];
  $(".multi-field-wrapper .loc-group").each(function (i, e) {
    var selected = $(e).val();
    if (selected !== null && selected.length !== 0) {
      _dataToSend['groups'].push(selected);
    }
  });
  // mode
  switch ($('#trans-mode :checked').attr("id")) {
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
  _dataToSend['locationList'] = [];
  // list
  for (var i = 1; i < $locs.length; i++) {
    entry = {};

    var $loc = $($locs[i]);
    var entryid = $loc.attr('id');
    var id = Number(entryid.split("-").pop());

    if (_sendGeo[id] === null) {
      entry['geocode'] = null;
      entry['searchtext'] = $('#' + entryid + " > h3").text();
    } else {
      var coord = _sendGeo[id].geometry.location;
      entry['geocode'] = {'lat': coord.lat(), 'lng': coord.lng()};
      entry['searchtext'] = getTagForAddress(_sendGeo[id]);
    }
    entry['minduration'] = $("#" + entryid + " .dur-A").val().toString();
    entry['maxduration'] = $("#" + entryid + " .dur-B").val().toString();
    entry['arriveafter'] = $("#" + entryid + " .time-start-A").val().toString();
    entry['arrivebefore'] = $("#" + entryid + " .time-start-B").val().toString();
    entry['departafter'] = $("#" + entryid + " .time-end-A").val().toString();
    entry['departbefore'] = $("#" + entryid + " .time-end-B").val().toString();
    entry['priority'] = Number($("#" + entryid + " .priority").val());
    _dataToSend['locationList'].push(entry);
  }
  // encapsulate
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
