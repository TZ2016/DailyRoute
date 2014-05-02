function statusChangeCallback2(response) {
  if (response.status === 'connected') {
    console.log("fixme: you are logged in!");
    fbLogin(response.authResponse);
  } else if (response.status === 'not_authorized') {
    console.log("fixme: dialog user not authorized");
  } else {
    console.log("fixme: you are not logged into facebook");
  }
}

// This function is called when someone finishes with the Login
// Button.  See the onlogin handler attached to it in the sample
// code below.
function checkLoginState() {
  FB.getLoginStatus(function(response) {
    statusChangeCallback2(response);
  });
}

window.fbAsyncInit = function() {
  FB.init({
    appId      : '719699764753215',
    cookie     : true,  // enable cookies to allow the server to access
    // the session
    xfbml      : true,  // parse social plugins on this page
    version    : 'v2.0' // use version 2.0
  });
//
//  FB.getLoginStatus(function(response) {
//    statusChangeCallback2(response);
//  });

};

// Load the SDK asynchronously
(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/sdk.js";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));

// successful.  See statusChangeCallback() for when this call is made.
function fbLogin(authResponse) {
  console.log('Welcome!  Fetching your information.... ');
  FB.api('/me', function(response) {
    console.log('Good to see you, ' + response.name + '.');
    console.log(JSON.stringify(response));

    // authReponse: accessToken, expiresIn, signedRequest, userID
    // response: id, email, first_name, gender, last_name, link, locale, name, timezone, updated_time, verified
    console.log("json-ified response");
    console.log(JSON.stringify(response));

    var _data = {'email': response.email }

    $.ajax({
      type: 'POST',
      url: 'signin_fb',
      data: JSON.stringify(_data),
      contentType: "application/json",
      dataType: "script",
      success: function (data, status, jqXHR) {
        console.log("success");
      },
      error: function (jqXHR, status, error) {
        $.alertMessage("internal error.");
      }
    });
  });
}