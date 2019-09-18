#!/bin/bash
# script to generate the api_module.js file
rm -f ./api.js
wget http://127.0.0.1:3000/api.js
cat begin.js api.js end.js > api_module.js