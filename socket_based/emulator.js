
/// CONFIG /////////////////

const TCP_PORT  = 5001;
const HTTP_PORT = 5002;

/// STATE /////////

const INPUTS_STATE_LEN  = 14;
const OUTPUTS_STATE_LEN = 52;

let inputs_state  = "0".repeat(INPUTS_STATE_LEN);
let outputs_state = "0".repeat(OUTPUTS_STATE_LEN);

/// TCP SOCKET /////////////////

const net = require('net');

const socket = net.createServer();    
socket.on('connection', handleConnection);

socket.listen(TCP_PORT, function() {    
  console.log('TCP Socket Listening on: ', socket.address());  
});

let conns = [];
let conns_refresh = false;

function handleConnection(conn) {    
  const remoteAddress = conn.remoteAddress + ':' + conn.remotePort;  
  console.log('New Simulator Connection: ', remoteAddress);

  conns.push(conn);
  conns_refresh = true;
  conn.on('data', onConnData);  
  conn.once('close', onConnClose);  
  conn.on('error', onConnError);

  function onConnData(d) {
    const new_outputs_state = d.toString().slice(0,-2);
    if(outputs_state !== new_outputs_state){
      outputs_state = new_outputs_state;
      console.log("NEW OUTPUT ", outputs_state, inputs_state);
    }
  }

  function onConnClose() {  
    console.log('Simulator Connection Closed: ', remoteAddress);
    conns = conns.filter(x => x !== conn)
  }

  function onConnError(err) {  
    console.error('Simulator Connection ERROR: ', remoteAddress, err.message);  
    conns = conns.filter(x => x !== conn)
  }
}


/// HTTP SERVER /////////////////

const http = require('http');
const fs = require("fs");

const http_requestHandler = (req, res) => {
  if(req.url.startsWith("/update/")){
    const new_inputs_state = req.url.slice(8);
    // console.log("Received");
    if(new_inputs_state.length == INPUTS_STATE_LEN && (new_inputs_state !== inputs_state || conns_refresh)){
      inputs_state = new_inputs_state;
      conns_refresh = false;
      // console.log("Updating");
      conns.forEach(x => x.write(inputs_state + '\r\n'));
      console.log("NEW INPUT  ", outputs_state, inputs_state);
    }
    res.end(outputs_state);
  }else{
    console.log("New HTTP Client");
    fs.readFile('emulator.html',function (err, data){
      res.writeHead(200, {'Content-Type': 'text/html','Content-Length':data.length});
      res.write(data);
      res.end();
    });
  }
}

const http_server = http.createServer(http_requestHandler);

http_server.listen(HTTP_PORT, (err) => {
  if (err) {
    return console.error(`Unable to start HTTP server on port ${HTTP_PORT}`, err);
  }

  console.log(`HTTP server listening on port ${HTTP_PORT}`)
})