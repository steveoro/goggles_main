#!/bin/sh

# Fail fast in case of errors:
set -e

# db:prepare is idempotent. This service starts only after `main` is healthy
# (see depends_on/service_healthy in docker-compose.prod.yml), so the queue and
# cable databases have already been created — this is a fast no-op safety net.
bundle exec rails db:prepare

# Start the Solid Queue supervisor (worker + dispatcher + scheduler):
exec bundle exec bin/jobs
