$(function() {
  var availableTags = [
    "San Francisco",
    "New York",
    "Berkeley"
  ];
  $( "#newloc" ).autocomplete({
    source: availableTags
  });
  $('#addloc-btn').click(function () {
    codeAddress();
  });
});
