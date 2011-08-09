# Soldat.js

This is currently version ZERO so don't expect clean code or something like that.

## Installation

Install node, npm and socket.io:

    $ brew install node
    $ curl http://npmjs.org/install.sh | sh
    $ npm install socket.io

Compile CoffeeScript files to JavaScript.

    $ coffee -cj lib/soldat.js src/(^server).coffee

Start server:

    $ coffee -co lib src/server.coffee
    $ node lib/server.js

