require('coffee-script/register');

var charge = require('../..'),
    http = require('http');

// create a new charge app
// charge automatically uses the config options in (__dirname + 'charge.json')
var app = charge(__dirname);

app.start(function(){
  console.log('server started on port 1111');
});
