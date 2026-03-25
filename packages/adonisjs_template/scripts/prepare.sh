#!/usr/bin/env sh
set -eu
sh scripts/write-env.sh
node scripts/ensure-knex-compat.js
