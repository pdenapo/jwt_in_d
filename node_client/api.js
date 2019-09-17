API_Interface = new function() {

var toRestString = function(v) {
var res;
switch(typeof(v)) {
case "object": res = JSON.stringify(v); break;
default: res = v;
}
return encodeURIComponent(res);
}

this.postSignIn = function(username, password, on_result, on_error) {
var url = "http://127.0.0.1:3000/api/sign_in";
var postbody = {
"username": username,
"password": password,
};
var xhr = new XMLHttpRequest();
xhr.open('POST', url, true);
xhr.onload = function () {
if (this.status >= 400) { if (on_error) on_error(JSON.parse(this.responseText)); else console.log(this.responseText); }
else on_result(JSON.parse(this.responseText));
};
xhr.onerror = function (e) { if (on_error) on_error(e); else console.log("XHR request failed"); }
xhr.setRequestHeader('Content-Type', 'application/json');
xhr.send(JSON.stringify(postbody));
}
}
