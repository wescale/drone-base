#!/usr/bin/env bash

set -e

buildArgs=""

while true; do
    case "$1" in
    --no-cache)
        buildArgs="--no-cache"
        shift ;;
    '')
        break;;
    *)
        echo "Invalid argument $1";
        exit 1
  esac
done


WST_NAME=wst-drone-base
USER_FOLDER=/root

docker stop -t0 $WST_NAME && docker rm $WST_NAME

docker build $buildArgs -t $WST_NAME -f ./workstation/Dockerfile ./workstation

docker run -td --name $WST_NAME \
    -v ~/.aws:$USER_FOLDER/.aws \
    -v ~/.ssh:$USER_FOLDER/.ssh \
    -v $(pwd)/:/workdir \
    $WST_NAME

docker exec -it $WST_NAME bash
