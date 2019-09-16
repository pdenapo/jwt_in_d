import vibe.web.rest;
import vibe.core.log;
//import std.stdio;
import std.conv;
import vibe.data.json;


interface API_Interface {
 string getMessage();
 Json getJsonMessage();
}

void main()
{
	auto api_client = new RestInterfaceClient!API_Interface("http://127.0.0.1:3000/api/");
	logInfo("api_client created");

	string menssage= api_client.getMessage();
	logInfo("message=" ~ menssage);
	
	Json json_menssage= api_client.getJsonMessage();
	logInfo("message=" ~ to!string(json_menssage));
}
