require('coffee-script/register');

var charge = require('../..');

// create a new charge app
var app = charge(__dirname);

// initialize a server
var server = app.start(function(err){
  if (err) return console.error(err);
  console.log('server started on port 1111');
});

// when the client connects, send a message and log to console
server.on('client_open', function(){
  console.log('client connected');
  server.send('socket connection established');
});

// when the client sends a message, log it to the console
server.on('message', function(msg){
  console.log(msg.data);
});

// when the client disconnects, log it to the console
server.on('client_close', function(){
  console.log('client disconnected');
});

// ping the client every second
setInterval(function(){ server.send('server: ping'); }, 1000);
