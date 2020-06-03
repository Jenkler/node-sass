"use strict";

const fs = require('fs');
const https = require('https');
const options = {
  cert: fs.readFileSync('localhost.crt'),
  key: fs.readFileSync('localhost.key')
};
const path = require('path');

https.createServer(options, function(request, response) {
  let url = request.url.split('?')[0];
  let filePath = './src/css' + url;
  if(url == '/') filePath = './src/css/custom.css';
  console.log('GET', filePath);

  let ext = String(path.extname(filePath)).toLowerCase();
  let mimeTypes = {'.css': 'text/css', '.html': 'text/html', '.js': 'text/javascript'};
  let contentType = mimeTypes[ext] || 'application/octet-stream';
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
