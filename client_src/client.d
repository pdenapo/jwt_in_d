import vibe.web.rest;
//import vibe.core.log;
import std.stdio;
import std.conv;
import std.string;
import vibe.data.json;
import vibe.web.auth;
import vibe.web.common; 
import vibe.http.client;
import core.thread;
import std.datetime.date;
import std.datetime.systime;
import core.time;

struct SigInMessage 
{
 string statusMessage;
 string AuthToken;
}

interface API_Interface {
	@anyAuth string getHello();
 	@safe SigInMessage postSignIn(string username, string password);
 	@noAuth SigInMessage postSignIn(string username, string password);
}


void do_api_calls(RestInterfaceClient!API_Interface api_client,string username,string password, const bool test_expired_tokens=false)
{ 
  // This function adds the jwt header for the authetithication 
  // It is a delegate: a local function with context
  
  SigInMessage sigin_response; 
  
  void add_jwt_header(HTTPClientRequest req) @safe
  {
   writeln("Method add_jwt_header called");
   req.headers["AuthToken"]= sigin_response.AuthToken;
   req.headers["AuthUser"]="username"; 
  }
 
  /* We log in using the api method */
 	
  sigin_response = api_client.postSignIn(username,password);
  writeln("sign_in_response.statusMessage=" ~ sigin_response.statusMessage);
  writeln("sign_in_response.AuthToken=" ~ sigin_response.AuthToken);
  api_client.requestFilter= &add_jwt_header;
  
  
  // If we want to test expired tokens, wait some seconds
  if (test_expired_tokens)
  {
   long currentTime_unix = Clock.currTime().toUnixTime();
   writeln("currentTime_unix =" ~ to!string(currentTime_unix));
  
  // wait some seconds
  Thread.sleep(5.seconds); 
 
  currentTime_unix = Clock.currTime().toUnixTime();
  writeln("currentTime_unix =" ~ to!string(currentTime_unix));
  }
 
  /* Now we do an API call */
   
  try{ 
      writeln("getHello=",api_client.getHello()); 
  } 
  catch(RestException e)
  {
	writeln("status=",e.status());
	writeln("result=",e.jsonResult());
  }
}

void main()
{
  auto api_client = new RestInterfaceClient!API_Interface("http://127.0.0.1:3000/api/");
  writeln("api_client created");

   
  writeln("\nWe first try to login with and invalid username & password combination");
  do_api_calls(api_client,"Mary","word");
  
    writeln("\nWe now log in with the right username & password but with an expried token"); 
  do_api_calls(api_client,"John","secret",true);	 
   
  writeln("\nFinally, we now log in with the right username & password, and a valid token"); 
  do_api_calls(api_client,"John","secret");	
}
