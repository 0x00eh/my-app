#!/bin/bash
IMAGE="us-central1-docker.pkg.dev/exemplary-oath-478810-g0/react-repo/react-app:latest"
CONTAINER="react-app"

docker pull $IMAGE
docker stop $CONTAINER || true
docker rm $CONTAINER || true
docker run -d --name $CONTAINER -p 80:80 $IMAGE
