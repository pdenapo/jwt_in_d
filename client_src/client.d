import vibe.web.rest;
//import vibe.core.log;
import std.stdio;
import std.conv;
import vibe.data.json;


struct SigInMessage 
{
 string message;
 string token;
}

interface API_Interface {
 	@safe SigInMessage postSignIn(string username, string password);
}


void main()
{
  auto api_client = new RestInterfaceClient!API_Interface("http://127.0.0.1:3000/api/");
  writeln("api_client created");

   /* We log in using the api method */
 
  SigInMessage sigin_response1 = api_client.postSignIn("pablo","pirulo");
  writeln("sign_in_response1.menssage=" ~ sigin_response1.message);
  writeln("sign_in_response1.token=" ~ sigin_response1.token);
   
  SigInMessage sigin_response2 = api_client.postSignIn("user","secret");
  writeln("sign_in_response2.menssage=" ~ sigin_response2.message);
  writeln("sign_in_response2.token=" ~ sigin_response2.token);


}
