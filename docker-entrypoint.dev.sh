#!/bin/bash
cd /app/ || exit

echo "store-dir = ${PNPM_HOME}/store" > /etc/npmrc
pnpm install --prefer-offline
pnpm knex migrate:latest
pnpm knex seed:run
pnpm start:dev
