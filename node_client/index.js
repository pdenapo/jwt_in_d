// We load the API generated by the server

var API = require("./api_module.js")

console.log(API)

console.log("Node.js test program for the API");

var mostrar_resultado = function (r) {
  console.log("respuesta=" + JSON.stringify(r))
}

console.log("postSignIn Mehod:")

API.postSignIn("John", "secret", mostrar_resultado)
