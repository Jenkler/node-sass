#!/bin/sh

if [ "$1" = 'cert' ]; then
  rm -rf localhost.crt localhost.key
  openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout rootca.key -out rootca.pem -subj "/C=US/CN=Jenkler-CA"
  openssl x509 -outform pem -in rootca.pem -out rootca.crt
  printf "authorityKeyIdentifier=keyid,issuer\nbasicConstraints=CA:FALSE\nkeyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n" > d.ext
  printf "subjectAltName = @alt_names\n[alt_names]\nDNS.1 = localhost\n" >> d.ext
  openssl req -new -nodes -newkey rsa:2048 -keyout localhost.key -out localhost.csr -subj "/C=SE/ST=Stockholm/L=Stockholm/O=Jenkler/CN=localhost"
  openssl x509 -req -sha256 -days 1024 -in localhost.csr -CA rootca.pem -CAkey rootca.key -CAcreateserial -extfile d.ext -out localhost.crt
  rm d.ext localhost.csr rootca.crt rootca.key rootca.pem rootca.srl
elif [ "$1" = 'compress' ]; then
  if [ -d 'node_modules' ]; then
    for f in src/scss/*.scss; do
      file="src/css.minified/$(basename $f | cut -f 1 -d '.').css"
      npx node-sass --output-style compressed $f | sed -r ':a; s%(.*)/\*.*\*/%\1%; ta; /\/\*/ !b; N; ba' > $file
      printf "Output: $file\n"
    done
  else
    printf "Error: Run npm install first!\n"
    exit 1
  fi
elif [ "$1" = 'server' ]; then
  if [ -f 'localhost.crt' ]; then
    node server.js
  else
    printf "Error: Generate cert first!\n"
    exit 1
  fi
elif [ "$1" = 'watch' ]; then
  if [ -d 'node_modules' ]; then
    npx node-sass --output src/css --recursive --watch src/scss
  else
    printf "Error: Run npm install first!\n"
    exit 1
  fi
else
  printf "Usage: $0 cert | compress | server | watch\n"
fi
