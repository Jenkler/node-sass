"use strict";

const fs = require('fs');
const https = require('https');
const options = {
  key: fs.readFileSync('localhost.key'),
  cert: fs.readFileSync('localhost.crt')
};
const path = require('path');

https.createServer(options, function(request, response) {
  let filePath = './src/css' + request.url;
  if(request.url == '/') {
    filePath = './src/css/custom.css';
  }
  console.log('GET', filePath);

  let extname = String(path.extname(filePath)).toLowerCase();
  let mimeTypes = {'.css': 'text/css', '.html': 'text/html', '.js': 'text/javascript'};
  let contentType = mimeTypes[extname] || 'application/octet-stream';
  fs.readFile(filePath, function(error, content) {
    if(error) {
      if(error.code == 'ENOENT') {
        response.writeHead(404, {'Content-Type': 'text/html'});
        response.end('Error: 404 ..\n');
      }
      else {
        response.writeHead(500);
        response.end('Error: '+error.code+' ..\n');
      }
    }
    else {
      response.writeHead(200, {'Content-Type': contentType});
      response.end(content, 'utf-8');
    }
  });
}).listen(8080);
console.log('Server running at https://localhost:8080/');
