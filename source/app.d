
/* This is a proof of concept of how to implement jwt  in D */

import jwtd.jwt;
import std.stdio;
import std.datetime.date;
import std.datetime.systime;
import std.json;
import std.conv;
import core.time;

import vibe.core.core;
import vibe.core.log;
import vibe.http.server;
import vibe.http.router;
import vibe.web.web;
import vibe.web.rest;


const string  secret = "My Token Generation Secret Key";

const my_url = "127.0.0.1";

const int my_port= 3000;



struct User
{
 string id;
}

interface APIRoot {
 string getMessage();
}


class API : APIRoot
{
	
	// Call it with http://127.0.0.1:3000/api/message 
	
	@safe override string getMessage()
	{
	  logInfo("get Message method called.");
	  return "Jwt example in D";
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
	render!("index.dt",my_url,my_port);
  }
}

void main()
{
 auto user = User("John");
 string token = createToken(user,10.days);
 writeln("\nThe generated web token is \n");
 writeln(token);
 writeln("\nYou can test it using the debugger at https://jwt.io/#debugger-io");
 
 
 auto settings = new HTTPServerSettings;
 settings.port =  my_port;
 settings.bindAddresses = [my_url];
  
 auto router = new URLRouter;
 router.registerWebInterface(new WebInterface);
 router.registerRestInterface(new API(),"/api");
 
 listenHTTP(settings, router);
 runApplication();	 	
}
