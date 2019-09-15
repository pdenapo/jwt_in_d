
/* This is a proof of concept of how to implement jwt  in D */

import jwtd.jwt;
import std.stdio;
import std.datetime.date;
import std.datetime.systime;
import std.json;
import std.conv;
import core.time : days;

const string  secret = "MiClaveDeTokens";

struct User
{
 string id;
}

string createToken(User who)
{
  JSONValue[string] payload;
  payload["sub"] = JSONValue(who.id);
  SysTime currentTime = Clock.currTime();
  payload ["iat"] =  JSONValue(currentTime.toUnixTime());
  DateTime current_date = to!DateTime(currentTime);
  DateTime expieraton_date =current_date + 10.days;
  payload["exp"] = JSONValue(to!SysTime(expieraton_date).toUnixTime());
  JSONValue payload_json= JSONValue(payload);
  writeln("Our payload in Json is:");
  writeln(payload_json);
  return encode(payload_json,"secret",JWTAlgorithm.HS256);  	
}

void main()
{
 auto user = User("John");
 writeln("The generated web token is");
 writeln(createToken(user));
 writeln("You can test it using the debugger at https://jwt.io/#debugger-io");	
}
