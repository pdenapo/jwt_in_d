# jwt_in_d

Example of using jwt in D

This is a proof on how to use jwt in D using jwtd (https://github.com/olehlong/jwtd).

See 

https://jwt.io/

to learn more about jwt.

The are also excelent resources in Youtube that have helped me for building
this example program:

* [What Is JWT and Why Should You Use JWT](https://www.youtube.com/watch?v=7Q17ubqLfaM)

* [Course on Rest APIs with node.js+ Mongo.db by Carlos Azaustre (in Spanish) ](https://www.youtube.com/playlist?list=PLUdlARNXMVkk7E88zOrphPyGdS50Tadlr)

* [Build A Node.js API Authentication With JWT Tutorial](https://www.youtube.com/watch?v=2jqok-WgelI) 

There are two programs: a server offering a Rest API and a client consuming it, both written in D using the vibe-d framework.

I started also writting a node.js client but I need to fix it.

Note: we use the version based on phobos in order to avoid an extra dependency. The version based on ssl fails to link for me, I don`t know why. I need to incluide it as a submodule sice I don`t know other way of telling dub which version I want. However, my forked version right now has no changes (It might have in a future).




