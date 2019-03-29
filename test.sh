#!/bin/sh

build/facile "$1.facile"
export TERM=xterm
ilasm "$1.il"

chmod 755 "$1.exe"
sh "$1.exe"