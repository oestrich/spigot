#/bin/bash
set -e

sha=`git rev-parse master`

rm -r tmp/build
mkdir -p tmp/build
git archive master | tar x -C tmp/build/
cd tmp/build

docker build --build-arg cookie=cookie -t oestrich/spigot:${sha} .
docker push oestrich/spigot:${sha}
