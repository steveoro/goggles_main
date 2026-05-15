#!/bin/bash
set -e

DEPLOY_DIR="$HOME/Projects/goggles_deploy"
COMPOSE_FILE="docker-compose.deploy_prod.yml"
ENV_FILE="$DEPLOY_DIR/.env"

touch "$ENV_FILE"
EXISTING_MYSQL_ROOT_PASSWORD="$(grep -m 1 '^MYSQL_ROOT_PASSWORD=' "$ENV_FILE" | cut -d= -f2- || true)"
EXISTING_TAG="$(grep -m 1 '^TAG=' "$ENV_FILE" | cut -d= -f2- || true)"
EXISTING_DOCKERHUB_USERNAME="$(grep -m 1 '^DOCKERHUB_USERNAME=' "$ENV_FILE" | cut -d= -f2- || true)"
EXISTING_DOCKERHUB_PASSWORD="$(grep -m 1 '^DOCKERHUB_PASSWORD=' "$ENV_FILE" | cut -d= -f2- || true)"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-$EXISTING_MYSQL_ROOT_PASSWORD}"
TAG="${TAG:-$EXISTING_TAG}"
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-$EXISTING_DOCKERHUB_USERNAME}"
DOCKERHUB_PASSWORD="${DOCKERHUB_PASSWORD:-$EXISTING_DOCKERHUB_PASSWORD}"

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "ERROR: MYSQL_ROOT_PASSWORD is not set and no existing value was found in $ENV_FILE"
  exit 1
fi

if [ -z "$TAG" ]; then
  echo "ERROR: TAG is not set and no existing value was found in $ENV_FILE"
  exit 1
fi

if [ -z "$DOCKERHUB_USERNAME" ]; then
  echo "ERROR: DOCKERHUB_USERNAME is not set and no existing value was found in $ENV_FILE"
  exit 1
fi

if [ -z "$DOCKERHUB_PASSWORD" ]; then
  echo "ERROR: DOCKERHUB_PASSWORD is not set and no existing value was found in $ENV_FILE"
  exit 1
fi

# Create a temporary docker config directory for login credentials
DEPLOY_DOCKER_CONFIG="$(mktemp -d)"
export DOCKER_CONFIG="$DEPLOY_DOCKER_CONFIG"
trap 'rm -rf "$DEPLOY_DOCKER_CONFIG"' EXIT

if docker compose version >/dev/null 2>&1; then
  compose() { docker compose "$@"; }
elif command -v docker-compose >/dev/null 2>&1; then
  compose() { docker-compose "$@"; }
else
  echo "ERROR: neither docker compose nor docker-compose is available"
  exit 1
fi

cd "$DEPLOY_DIR"
pwd
echo Using tag $TAG
echo "WARNING: This will reset the job queue (hard switch to Solid Queue)"
echo Logging into DockerHub...
printf '%s\n' "$DOCKERHUB_PASSWORD" | docker login --username "$DOCKERHUB_USERNAME" --password-stdin
# Since vers. 0.9+, we dropped the "prod-" prefix from the tag:
docker pull "$DOCKERHUB_USERNAME/goggles-main:$TAG"
docker pull "$DOCKERHUB_USERNAME/goggles-api:$TAG"
echo ""
echo "Stopping services and clearing old job queues..."
compose -f "$COMPOSE_FILE" down
mkdir -p "$DEPLOY_DIR/storage.prod"
# Clear any existing SQLite queue/cache files for clean start
rm -f "$DEPLOY_DIR/storage.prod/production_queue.sqlite3"
rm -f "$DEPLOY_DIR/storage.prod/cache.sqlite3"
echo "Updating .env file with new tagged release..."
grep -v -E '^(MYSQL_ROOT_PASSWORD|TAG|DOCKERHUB_USERNAME|DOCKERHUB_PASSWORD|MARIADB_AUTO_UPGRADE|MARIADB_INITDB_SKIP_TZINFO)=' "$ENV_FILE" > "$ENV_FILE.tmp" || true
mv "$ENV_FILE.tmp" "$ENV_FILE"
printf 'MYSQL_ROOT_PASSWORD=%s\n' "$MYSQL_ROOT_PASSWORD" >> "$ENV_FILE"
printf 'TAG=%s\n' "$TAG" >> "$ENV_FILE"
printf 'DOCKERHUB_USERNAME=%s\n' "$DOCKERHUB_USERNAME" >> "$ENV_FILE"
printf 'DOCKERHUB_PASSWORD=%s\n' "$DOCKERHUB_PASSWORD" >> "$ENV_FILE"
printf 'MARIADB_AUTO_UPGRADE=1\n' >> "$ENV_FILE"
printf 'MARIADB_INITDB_SKIP_TZINFO=1\n' >> "$ENV_FILE"
echo "Starting MariaDB and waiting for readiness..."
compose -f "$COMPOSE_FILE" up -d goggles-db
compose -f "$COMPOSE_FILE" exec -T goggles-db sh -c 'until mariadb-admin ping -h 127.0.0.1 -uroot -p"$MYSQL_ROOT_PASSWORD" --silent; do sleep 2; done'
echo "Starting services with new Rails 8.1 stack..."
compose -f "$COMPOSE_FILE" up -d api main
echo "Finished. Job queue has been reset for Solid Queue migration."
