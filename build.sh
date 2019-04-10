# Utilisation build.sh path/to/facile name

echo "\nRebuilding..."
rm -rf ./build ./dist
mkdir build
mkdir dist

echo "\nUse 'cmake -DCMAKE_BUILD_TYPE=Debug' for more verbose output. Compiling..."
cd build/
cmake ../src
make 

echo "\nMoving executable to dist..."
cd ../
mv build/facile dist/
