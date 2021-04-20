#!/bin/bash

cd ~/Projects/goggles_deploy
pwd
echo Logging into DockerHub...
echo $DOCKERHUB_PASSWORD | docker login --username "$DOCKERHUB_USERNAME" --password-stdin
docker pull $DOCKERHUB_USERNAME/goggles-main:latest
docker pull $DOCKERHUB_USERNAME/goggles-api:latest
echo ""
docker-compose -f docker-compose.deploy_staging.yml down
docker-compose -f docker-compose.deploy_staging.yml up -d
echo "Finished."
