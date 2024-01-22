#!/bin/sh
path=$(realpath "$0")
cd "$(dirname "$path")" || exit;
[ "$(id -u)" -eq 0 ] && printf 'This script can not be run as root\n' && exit 1;
[ -x "$(command -v openssl)" ] || { printf 'Missing: openssl\n' && exit 1; }
[ -x "$(command -v node)" ] || { printf 'Missing: node\n' && exit 1; }
[ -x "$(command -v npm)" ] || { printf 'Missing: npm\n' && exit 1; }

jcert() {
  rm -fr src/localhost*
  openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout rootca.key -out rootca.pem -subj "/C=US/CN=Jenkler-CA"
  openssl x509 -outform pem -in rootca.pem -out rootca.crt
  printf "authorityKeyIdentifier=keyid,issuer\nbasicConstraints=CA:FALSE\nkeyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n" > d.ext
  printf "subjectAltName = @alt_names\n[alt_names]\nDNS.1 = localhost\n" >> d.ext
  openssl req -new -nodes -newkey rsa:2048 -keyout localhost.key -out localhost.csr -subj "/C=SE/ST=Stockholm/L=Stockholm/O=Jenkler/CN=localhost"
  openssl x509 -req -sha256 -days 1024 -in localhost.csr -CA rootca.pem -CAkey rootca.key -CAcreateserial -extfile d.ext -out localhost.crt
  rm d.ext localhost.csr rootca.crt rootca.key rootca.pem rootca.srl
  mv localhost* src/
}
jclean() {
  rm -fr node_modules package-lock.json src/localhost* src/minify src/js src/watch
}
jjs() {
  [ -d 'src/js' ] || mkdir -p src/js
  [ -d 'node_modules' ] || npm install
  grep -h 'function' node_modules/@popperjs/core/dist/umd/popper.min.js node_modules/bootstrap/dist/js/bootstrap.min.js > src/js/custom.js
  printf 'Output: src/js/custom.js\n'
}
jminify() {
  [ -d 'src/minify' ] || mkdir -p src/minify
  [ -d 'node_modules' ] || npm install
  for f in src/scss/*.scss; do
    [ "$(basename "$f" | cut -c 1)" = '_' ] && continue
    out="src/minify/$(basename "${f%.*}").css"
    npx sass --style compressed "$f" | tr -d '\n' | sed 's/\/\*!.* \*\/:root/:root/' > "$out"
    printf 'Output: %s\n' "$out"
  done
}
jserver() {
  [ -f 'src/localhost.crt' ] || ./generate.sh cert
  node src/server.js
}
jwatch() {
  [ -d 'src/watch' ] || mkdir -p src/watch
  [ -d 'node_modules' ] || npm install
  printf 'Waitning for file modification in src/scss\n'
  npx sass --no-source-map --watch src/scss/:src/watch/
}
[ "$1" != 'cert' ] && [ "$1" != 'clean' ] && [ "$1" != 'js' ] && [ "$1" != 'minify' ] && [ "$1" != 'server' ] && [ "$1" != 'watch' ] &&
  printf 'Usage: %s cert | clean | js | minify | server | watch\n' "$path" && exit
{ [ "$1" = 'cert' ] && jcert; } ||
{ [ "$1" = 'clean' ] && jclean; } ||
{ [ "$1" = 'js' ] && jjs; } ||
{ [ "$1" = 'minify' ] && jminify; } ||
{ [ "$1" = 'server' ] && jserver; } ||
{ [ "$1" = 'watch' ] && jwatch; }
