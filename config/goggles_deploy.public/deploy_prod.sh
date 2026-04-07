#!/bin/bash

cd ~/Projects/goggles_deploy
pwd
echo Using tag $TAG
echo "WARNING: This will reset the job queue (hard switch to Solid Queue)"
echo Logging into DockerHub...
echo $DOCKERHUB_PASSWORD | docker login --username "$DOCKERHUB_USERNAME" --password-stdin
docker pull $DOCKERHUB_USERNAME/goggles-main:prod-$TAG
docker pull $DOCKERHUB_USERNAME/goggles-api:prod-$TAG
echo ""
echo "Stopping services and clearing old job queues..."
docker-compose -f docker-compose.deploy_prod.yml down
# Clear any existing SQLite queue/cache files for clean start
rm -f ~/Projects/goggles_deploy/storage.prod/queue.sqlite3
rm -f ~/Projects/goggles_deploy/storage.prod/cache.sqlite3
echo "Updating .env file with new tagged release..."
echo "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" > .env
echo "TAG=$TAG" >> .env
echo "Starting services with new Rails 8.1 stack..."
docker-compose -f docker-compose.deploy_prod.yml up -d
echo "Finished. Job queue has been reset for Solid Queue migration."
