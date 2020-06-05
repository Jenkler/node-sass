#!/bin/sh
if [ ! -x "$(command -v node)" ]; then
  printf 'Missing: node\n'
  exit 1
fi
if [ ! -x "$(command -v npm)" ]; then
  printf 'Missing: npm\n'
  exit 1
fi
if [ "$1" = 'cert' ]; then
  rm -fr src/localhost*
  openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout rootca.key -out rootca.pem -subj "/C=US/CN=Jenkler-CA"
  openssl x509 -outform pem -in rootca.pem -out rootca.crt
  printf "authorityKeyIdentifier=keyid,issuer\nbasicConstraints=CA:FALSE\nkeyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n" > d.ext
  printf "subjectAltName = @alt_names\n[alt_names]\nDNS.1 = localhost\n" >> d.ext
  openssl req -new -nodes -newkey rsa:2048 -keyout localhost.key -out localhost.csr -subj "/C=SE/ST=Stockholm/L=Stockholm/O=Jenkler/CN=localhost"
  openssl x509 -req -sha256 -days 1024 -in localhost.csr -CA rootca.pem -CAkey rootca.key -CAcreateserial -extfile d.ext -out localhost.crt
  rm d.ext localhost.csr rootca.crt rootca.key rootca.pem rootca.srl
  mv localhost* src/
elif [ "$1" = 'clean' ]; then
  rm -fr node_modules package-lock.json src/localhost* src/css src/js src/watch
elif [ "$1" = 'compress' ]; then
  if [ ! -d 'src/css' ]; then mkdir -p src/css; fi
  if [ ! -d 'node_modules' ]; then npm install; fi
  for f in src/scss/*.scss; do
    file=$(basename $f)
    if [ "${file:0:1}" = '_' ]; then continue; fi
    out="src/css/$(basename $f | cut -f 1 -d '.').css"
    npx node-sass --output-style compressed $f | tr -d '\n' | sed 's/\/\*.*\*\///' > $out
    printf "Output: $out\n"
  done
elif [ "$1" = 'js' ]; then
  if [ ! -d 'src/js' ]; then mkdir -p src/js; fi
  if [ ! -d 'node_modules' ]; then npm install; fi
  cat node_modules/popper.js/dist/umd/popper.min.js | sed '/\/\/#/d' | tr -d '\n' | sed 's/\/\*.*\*\///' > src/js/custom.js
  cat node_modules/bootstrap/dist/js/bootstrap.min.js | sed '/\/\/#/d' | tr -d '\n' | sed 's/\/\*.*\*\///' >> src/js/custom.js
  printf "Output: src/js/custom.js\n"
elif [ "$1" = 'server' ]; then
  if [ ! -f 'src/localhost.crt' ]; then ./generate.sh cert; fi
  node src/server.js
elif [ "$1" = 'watch' ]; then
  if [ ! -d 'src/watch' ]; then mkdir -p src/watch; fi
  if [ ! -d 'node_modules' ]; then npm install; fi
  printf "Waitning for file modification in src/scss\n"
  npx node-sass --output src/watch --recursive --watch src/scss
else
  printf "Usage: $0 cert | clean | compress | js | server | watch\n"
fi
