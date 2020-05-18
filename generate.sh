#!/bin/sh

if [ "$1" = 'compress' ]; then
  for f in src/scss/*.scss; do
    npx node-sass --output-style compressed $f | sed -r ':a; s%(.*)/\*.*\*/%\1%; ta; /\/\*/ !b; N; ba' > src/css.minified/$(basename $f | cut -f 1 -d '.').css
  done
elif [ "$1" = 'watch' ]; then
  npx node-sass --output src/css --recursive --watch src/scss
else
  printf "Usage: $0 compress | watch\n"
fi
