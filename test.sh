#!/bin/sh

cd ../test/
../build/facile "$2.facile"
export TERM=xterm
ilasm "$2.il"

chmod 755 "$2.exe"
./"$2.exe"