#!/usr/bin/env sh
set -eu
unset NO_COLOR
tmp_pg_root=""
if [ -z "${PGDATA:-}" ] || [ -z "${PGHOST:-}" ]; then
  tmp_pg_root="$(mktemp -d /tmp/adonisjs-template-pg-XXXXXX)"
fi
export PGDATA="${PGDATA:-$tmp_pg_root/.postgres}"
export PGHOST="${PGHOST:-$tmp_pg_root/socket}"
export PGPORT="${PGPORT:-5432}"
export PGUSER="${PGUSER:-postgres}"
export PGPASSWORD="${PGPASSWORD:-postgres}"
export PGDATABASE="${PGDATABASE:-adonisjs_template}"
export DB_HOST="${DB_HOST:-$PGHOST}"
export DB_PORT="${DB_PORT:-$PGPORT}"
export DB_USER="${DB_USER:-$PGUSER}"
export DB_PASSWORD="${DB_PASSWORD:-$PGPASSWORD}"
export DB_DATABASE="${DB_DATABASE:-$PGDATABASE}"
cleanup() {
  npm run db:stop || true
  if [ -n "$tmp_pg_root" ]; then
    rm -rf "$tmp_pg_root"
  fi
}
trap cleanup EXIT
npm run db:start
npm run db:createdb
npm run db:migrate
npm run clean
npm exec tsc -- --noEmit
npm run build
npm run test:coverage
npm run test:mutation
NODE_ENV=production E2E_MODE=prod node node_modules/playwright/cli.js test \
  --config=playwright.config.ts \
  --project=chromium \
  --project=audit
npm run test:lint
