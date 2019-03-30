#!/bin/sh

#==========================================
# Synopsis: sh test.sh path/to/folder(1)
#==========================================
# (1): folder must containt .facile file

buildPath=$(realpath dist)
testPath=$(realpath $1)
facileFile=$(find $testPath -name "*.facile")

echo "Cleaning up exes and il"
find $testPath -name "*.il" -exec rm {} +
find $testPath -name "*.exe" -exec rm {} +

cd $testPath

facileFile=${facileFile##*/}
fileName=${facileFile%.facile}

echo "Assembling from facile..."
$buildPath/facile "$fileName.facile"
export TERM=xterm #stupid compilation error fixed

echo "Compiling from .il file..."
ilasm $fileName.il
chmod 755 $fileName.exe
./$fileName.exe