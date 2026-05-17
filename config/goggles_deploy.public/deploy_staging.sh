#!/bin/bash

cd ~/Projects/goggles_deploy
pwd
echo "WARNING: This will reset the job queue (hard switch to Solid Queue)"
echo Logging into DockerHub...
echo $DOCKERHUB_PASSWORD | docker login --username "$DOCKERHUB_USERNAME" --password-stdin
docker pull $DOCKERHUB_USERNAME/goggles-main:latest
docker pull $DOCKERHUB_USERNAME/goggles-api:latest
echo ""
echo "Stopping services and clearing old job queues..."
docker-compose -f docker-compose.deploy_staging.yml down
# Clear any existing SQLite queue/cache files for clean start
rm -f ~/Projects/goggles_deploy/storage.staging/staging_queue.sqlite3
rm -f ~/Projects/goggles_deploy/storage.staging/cache.sqlite3
echo "Starting services with new Rails 8.1 stack..."
docker-compose -f docker-compose.deploy_staging.yml up -d
echo "Finished. Job queue has been reset for Solid Queue migration."
