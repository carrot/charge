require('coffee-script/register')

var charge = require('../..');

// create a new charge app
var app = charge(__dirname);

// pass it to the server
app.start(function(err){
  if (err) return console.error(err);
  console.log('server started on port 1111');
});

// when the client connects, send a message
app.on('connection', function(){
  app.send('socket connection established');
});

// when the client sends a message, log it to the console
app.on('message', function(msg){
  console.log(msg.data);
});

// ping the client every second
setInterval(function(){ app.send('server: ping') }, 1000);
