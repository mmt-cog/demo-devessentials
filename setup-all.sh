#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "No argument provided. Please use 'up', 'down', 'debug', or 'initial'."
  exit 1
fi

if [ -f .env ]; then
    echo "✅ .env file exists. Happy coding!"

    start_datetime=$(date +"%Y-%m-%d %T")
    echo "Current date and time: $start_datetime"

else
    echo "❌ .env file does not exist! Copy .env.example as .env and customize it for your needs before running the setup-all. Exiting now..."
    exit 1
fi


set -a
source .env
set +a

debug_action () {
    if [ "$1" == "debug" ]; then
        echo "SQL_PASSWORD==> $SQL_PASSWORD"
        echo "MAIN_VERSION==> $MAIN_VERSION"
        echo "SENDMAIL_VERSION==> $SENDMAIL_VERSION"
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

    echo "Start time: $start_datetime"
    echo "All done time: $(date +"%Y-%m-%d %T")"
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