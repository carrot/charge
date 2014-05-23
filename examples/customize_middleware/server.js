require('coffee-script/register')

var charge = require('../..'),
    connect = require('connect'),
    http = require('http');

// create a new charge app
var app = charge(__dirname);

// replace current logger as first in the stack
app.stack.splice(0, 1, { route: '', handle: connect.logger('short') });

http.createServer(app).listen(1111);
