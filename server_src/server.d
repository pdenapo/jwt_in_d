
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
import vibe.web.auth;
import vibe.web.web;
import vibe.web.rest;
import vibe.inet.url;
//import vibe.data.json;

const string server_secret_key = "My Token Generation Secret Key";

const my_address = "127.0.0.1";

const int my_port= 3000;

const Duration token_duration = 2.seconds;

struct User
{
 string id;
}

struct SigInMessage 
{
 string statusMessage;
 string AuthToken;
}

@requiresAuth
interface API_Interface {
 @anyAuth string getHello();	
 @noAuth SigInMessage postSignIn(string username, string password);
 @noRoute AuthInfo authenticate(scope HTTPServerRequest req, scope HTTPServerResponse res);
}

// If a parameter is missing, we get a message like {"statusMessage":"Missing non-optional query parameter 'authorization'."}	

static struct AuthInfo {
@safe:
	string userName;

//  You can use this to define different user roles
//	bool isAdmin() { return this.userName == "tom"; }
}

@requiresAuth
class API:API_Interface
{
	// This is useful so that all methods can access the authorization info
	private AuthInfo auth_info;
	
	// This function checks the user jwt token
	
	@noRoute override AuthInfo authenticate(scope HTTPServerRequest req, scope HTTPServerResponse res)
	{
		logInfo("AuthInfo method called");
		
		JSONValue payload_json;
		logInfo("Decoding jwt token");
		try
		{
		 payload_json = decode(req.headers["AuthToken"],server_secret_key);
		}
		catch (VerifyException)
		{
		  throw new HTTPStatusException(HTTPStatus.unauthorized,"Invalid Token");	
		}
			
		logInfo("payload=" ~ to!string(payload_json));		
				
		 /* We check that the token has not expired */	 
		 long currentTime_unix = Clock.currTime().toUnixTime();
		 logInfo("currentTime_unix =" ~ to!string(currentTime_unix));
		
		 if ("exp" in payload_json)
		 {
		 	
		 	long expiration_time = payload_json["exp"].integer; 
		 	logInfo("expiration_time =" ~ to!string(expiration_time));
		 	if (expiration_time<currentTime_unix)
		 	{
		 	 logInfo("Expired token");
		 	 throw new HTTPStatusException(HTTPStatus.unauthorized,"Expired token");
		 	}
		 }
			 
		 	 this.auth_info = AuthInfo(payload_json["sub"].str);
			 return this.auth_info;
	}
	
	// Call it url http://127.0.0.1:3000/api/hello 

	//If you want to pass a parameter in the header use something like @headerParam("name", "AuthUser")
	
	@anyAuth @safe override string getHello()
	{
	 logInfo("getHello method called");
	 return "Hello " ~ this.auth_info.userName ~" from Jwt Example in D";
	}
		
	// Method for user Sing In
	
	@noAuth override SigInMessage postSignIn(string username, string password)
	{  
	   logInfo("postSignIn method called");
	   
	   /* We check if the user has the right credetials. 
	   /* Todo: implement SignUp and store the users in a database */
	   	   
	   if (username == "John" && password== "secret") 
	   {
	    auto user = User(username);
	    string token = createToken(user,token_duration);
	    return SigInMessage("Sucesfully Logged in", token);
	   }
	  else 
	   return SigInMessage("Invalid user/password combination", "");
	}
	
}


string createToken(User who,  Duration expiration_duration)
{
  JSONValue[string] payload;
  payload["sub"] = JSONValue(who.id);
  SysTime currentTime = Clock.currTime();
  payload ["iat"] =  JSONValue(currentTime.toUnixTime());
  DateTime current_date = to!DateTime(currentTime);
  if (expiration_duration)
  {
    DateTime expieraton_date =current_date + expiration_duration ;
    payload["exp"] = JSONValue(to!SysTime(expieraton_date).toUnixTime());
  }
  JSONValue payload_json= JSONValue(payload);
  logInfo("created token" ~ to!string(payload_json));
  return encode(payload_json,server_secret_key,JWTAlgorithm.HS256);  	
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
  
 auto settings = new HTTPServerSettings;
 settings.port =  my_port;
 settings.bindAddresses = [my_address];
  
 auto router = new URLRouter;
 router.registerWebInterface(new WebInterface);
 
 API my_API= new API();
 auto rest_settings = new RestInterfaceSettings();
 rest_settings.baseURL= URL("http://" ~ my_address ~ ":" ~ to!string(my_port) ~ "/api");
 
 router.registerRestInterface(my_API,rest_settings);
  
 // generates a JS file for using the API uncomment this line 
 router.get("/api.js", serveRestJSClient!API_Interface(rest_settings));
 
 listenHTTP(settings, router);
 runApplication();	 	
}
