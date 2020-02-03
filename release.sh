#!/bin/bash
set -e

DOCKER_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

mkdir -p tmp/

docker build -f Dockerfile.releaser -t spigot:releaser .

docker run -ti --name spigot_releaser_${DOCKER_UUID} spigot:releaser /bin/true
docker cp spigot_releaser_${DOCKER_UUID}:/opt/spigot.tar.gz tmp/
docker rm spigot_releaser_${DOCKER_UUID}
