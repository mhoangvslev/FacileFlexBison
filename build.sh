# Utilisation build.sh path/to/facile name

echo "\nRebuilding..."
rm -rf ./build ./dist
mkdir build
mkdir dist

echo "\nCompiling..."
cd build/
cmake -DCMAKE_BUILD_TYPE=Debug ../src
make 

echo "\nMoving executable to dist..."
cd ../
mv build/facile dist/
