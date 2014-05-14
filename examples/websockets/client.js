!(function(){
  // initialize websockets
  var loc = window.location;
  var protocol = loc.protocol === 'http:' ? 'ws://' : 'wss://';
  var address = protocol + loc.host + loc.pathname + '/ws';
  var sock = new WebSocket(address);

  // grab the div we'll append the results to
  var log = document.getElementById('log');

  // add an onmessage handler to recieve messages from the server
  sock.onmessage = handle_msg;
  function handle_msg(msg){
    log.innerHTML += "<p>" + msg.data + "</p>";
  }

  // add onclose handler for if the server ends the connection
  sock.onclose = handle_close;
  function handle_close(msg){
    log.innerHTML += "<p>server disconnected</p>";
  }

  // send data to the server from the button
  var button = document.getElementById('button');
  button.onclick = function(){ sock.send('hello from the client!'); }
}());
