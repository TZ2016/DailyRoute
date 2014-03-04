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
  $( '#addloc-btn' ).click(function () {
    var address = document.getElementById('newloc').value;
    var newitem = $( "#loc-tmp" ).clone().text(address).removeAttr("id style")

    $( "#locs" ).append(newitem)
    codeAddress(address);
  });

  // sortable
  $( "#locs" ).sortable();
  $( "#locs" ).disableSelection();
});
