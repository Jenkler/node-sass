# node-sass

A tool for generating custom bootstrap css and js files.

## Generate cert for local web server
- ./generate.sh cert
## Clean node-sass from generated files and build dependencies
- ./generate.sh clean
## Generate javascript file
- ./generate.sh js
## Generate files from scss
- ./generate.sh minify
## Start local web server
- ./generate.sh server
## Keep watching the files in scss folder. This is used for dev mode
- ./generate.sh watch

# Notes
- Enable 'Allow invalid certificates for resources loaded from localhost.' in chrome://flags/
