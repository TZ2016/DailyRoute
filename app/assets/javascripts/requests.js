$(document).on('click', 'form .remove_fields', function (event) { //FIXME
  $(this).prev('input[type=hidden]').val('1');
  $(this).closest('fieldset').hide();
  return event.preventDefault();
});

$(document).on('click', 'form .add_fields', function (event) {
  var regexp, time;
  time = new Date().getTime();
  regexp = new RegExp($(this).data('id'), 'g');
  $(this).before($(this).data('fields').replace(regexp, time)); //FIXME
  $("#loc-acc").accordion("refresh"); //FIXME
  return event.preventDefault();
});