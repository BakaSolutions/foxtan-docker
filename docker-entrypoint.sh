#!/bin/bash
cd /app/ || exit

CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e /$CONTAINER_ALREADY_STARTED ]; then
    touch /$CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"
    npx -- knex migrate:latest
    npx -- knex seed:run
else
    echo "-- Not first container startup --"
fi

npm start
