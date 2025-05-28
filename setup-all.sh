#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "No argument provided. Please use 'up', 'down', 'debug', or 'initial'."
  exit 1
fi

set -a
source .env
set +a

debug_action () {
    if [ "$1" == "debug" ]; then
        echo "SQL_PASSWORD==> $SQL_PASSWORD"
    fi
}



case "$1" in
  up)
    docker-compose -f setup/docker-compose.yml up -d
    docker-compose -f src/azure-functions/docker-compose.yml up -d
    ;;
  down)
    docker-compose -f setup/docker-compose.yml down
    docker-compose -f  src/azure-functions/docker-compose.yml down
    ;;
  initial)
    docker-compose -f setup/docker-compose.yml up -d

    setup-db/setup-sqlserver-db.sh

    docker-compose -f  src/azure-functions/docker-compose.yml up -d
    ;;
  debug)
    echo "Debug mode. No actions other than rendering variables"
    debug_action $1
    ;;
  *)
    echo "Invalid argument. Please use 'up', 'down', 'initial', or 'debug'."
    exit 1
    ;;
esac