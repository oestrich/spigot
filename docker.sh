#/bin/bash
set -e

rm -r tmp/build
mkdir -p tmp/build
git archive master | tar x -C tmp/build/
cd tmp/build

docker build --build-arg cookie=cookie -t oestrich/spigot:master .
