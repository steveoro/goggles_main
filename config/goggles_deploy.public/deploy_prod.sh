#!/bin/bash

cd ~/Projects/goggles_deploy
pwd
echo Using tag $TAG
echo Logging into DockerHub...
echo $DOCKERHUB_PASSWORD | docker login --username "$DOCKERHUB_USERNAME" --password-stdin
docker pull $DOCKERHUB_USERNAME/goggles-main:prod-$TAG
docker pull $DOCKERHUB_USERNAME/goggles-api:prod-$TAG
echo ""
docker-compose -f docker-compose.deploy_prod.yml down
echo "Updating .env file with new tagged release..."
echo "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" > .env
echo "TAG=$TAG" >> .env
docker-compose -f docker-compose.deploy_prod.yml up -d
echo "Finished."
