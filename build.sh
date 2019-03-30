# Utilisation build.sh path/to/facile name

echo "Rebuilding..."
rm -rf ./build ./dist
mkdir build
mkdir dist

echo "Compiling..."
cd build/
cmake ../src
make 

echo "Moving executable to dist..."
cd ../
mv build/facile dist/
