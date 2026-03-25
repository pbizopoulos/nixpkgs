#!/usr/bin/env sh
set -eu
export PGDATA="${PGDATA:-$PWD/tmp/.postgres}"
export PGHOST="${PGHOST:-/tmp/adonisjs-template-pg}"
export PGPORT="${PGPORT:-5432}"
export PGUSER="${PGUSER:-postgres}"
export PGPASSWORD="${PGPASSWORD:-postgres}"
export PGDATABASE="${PGDATABASE:-adonisjs_template}"
cleanup() {
  npm run db:stop
}
trap cleanup EXIT
npm run db:start
npm run db:createdb
npm run db:migrate
npm run clean
npm exec tsc -- --noEmit
npm exec vitest run -- --coverage
npm run build
E2E_MODE=prod node node_modules/playwright/cli.js test \
  --config=playwright.config.ts \
  --project=chromium \
  --project=audit
npm run test:lint
npm run test:mutation
