require('coffee-script/register')

var charge = require('../..'),
    http = require('http');

// create a new charge app
var app = charge(__dirname);
http.createServer(app).listen(1111);
