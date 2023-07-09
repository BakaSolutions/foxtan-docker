#!/bin/bash
cd /app/ || exit

pnpm knex migrate:latest
pnpm start
