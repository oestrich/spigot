#!/bin/bash
set -e

SHA=`git rev-parse HEAD`

if [ -z ${COOKIE+x} ]; then
  COOKIE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
fi

DOCKER_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

mkdir -p tmp/

docker build --build-arg sha=${SHA} --build-arg cookie=${COOKIE} -f Dockerfile.releaser -t spigot:releaser .

docker run -ti --name spigot_releaser_${DOCKER_UUID} spigot:releaser /bin/true
docker cp spigot_releaser_${DOCKER_UUID}:/app/_build/prod/rel/spigot/releases/0.1.0/spigot.tar.gz tmp/
docker rm spigot_releaser_${DOCKER_UUID}
