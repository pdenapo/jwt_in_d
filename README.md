# jwt_in_d

Example of using jwt in D

This is a proof on how to use jwt in D using jwtd (https://github.com/olehlong/jwtd).

See 

https://jwt.io/

to learn more about jwt.

There are two programs: a server offering a Rest API and a client consuming it, both written in D using the vibe-d framework.

I started also writting a node.js client but I need to fix it.

Note: we use the version based on phobos in order to avoid an extra dependency. The version based on ssl fails to link for me, I don`t know why. I need to incluide it as a submodule sice I don`t know other way of telling dub which version I want. However, my forked version right now has no changes (It might have in a future).




