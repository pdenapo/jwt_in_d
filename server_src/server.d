
/* This is a proof of concept of how to implement jwt  in D */

module server;

import jwtd.jwt;
import std.stdio;
import std.datetime.date;
import std.datetime.systime;
import std.json;
import std.conv;
import core.time;
import std.array;

import vibe.core.core;
import vibe.core.log;
import vibe.http.router;
import vibe.http.server;
import vibe.web.web;
import vibe.web.rest;
import vibe.inet.url;
import vibe.data.json;

const string  secret = "My Token Generation Secret Key";

const my_address = "127.0.0.1";

const int my_port= 3000;

string token;

struct User
{
 string id;
}

struct SigInMessage 
{
 string message;
 string token;
}

interface API_Interface {
 SigInMessage postSignIn(string username, string password);
}


class API:API_Interface
{
	
	// Call it with http://127.0.0.1:3000/api/message 
		
	@safe override SigInMessage postSignIn(string username, string password)
	{
	  if (username == "user" && password== "secret") 
	    return SigInMessage("Sucesfully Logged in", token);
	  else 
	   return SigInMessage("Invalid user/passwod comination", "");
	}
	
}


string createToken(User who,  Duration expiration_time)
{
  JSONValue[string] payload;
  payload["sub"] = JSONValue(who.id);
  SysTime currentTime = Clock.currTime();
  payload ["iat"] =  JSONValue(currentTime.toUnixTime());
  DateTime current_date = to!DateTime(currentTime);
  DateTime expieraton_date =current_date + expiration_time ;
  payload["exp"] = JSONValue(to!SysTime(expieraton_date).toUnixTime());
  JSONValue payload_json= JSONValue(payload);
  writeln("Our payload in Json is:\n");
  writeln(payload_json);
  return encode(payload_json,"secret",JWTAlgorithm.HS256);  	
}


class WebInterface
{
  
  // GET /
  void index()
  {
	render!("index.dt",my_address,my_port);
  }
}

void main()
{
 auto user = User("John");
 token = createToken(user,10.days);
 writeln("\nThe generated web token is \n");
 writeln(token);
 writeln("\nYou can test it using the debugger at https://jwt.io/#debugger-io");
 
 
 auto settings = new HTTPServerSettings;
 settings.port =  my_port;
 settings.bindAddresses = [my_address];
  
 auto router = new URLRouter;
 router.registerWebInterface(new WebInterface);
 
 API my_API= new API();
 auto rest_settings = new RestInterfaceSettings();
 rest_settings.baseURL= URL("http://" ~ my_address ~ ":3000/api");
 
 router.registerRestInterface(my_API,rest_settings);
  
 // generates a JS file for using the API uncomment this line 
 router.get("/api.js", serveRestJSClient!API_Interface(rest_settings));
 
 listenHTTP(settings, router);
 runApplication();	 	
}
