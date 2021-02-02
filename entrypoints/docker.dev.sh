#!/bin/sh

# Fail fast in case of errors:
set -e

# Don't block server start in case a previous PID file is left:
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Start our server:
bundle exec rails s -b 0.0.0.0 -p 8080
