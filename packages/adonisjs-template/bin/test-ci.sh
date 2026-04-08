#!/usr/bin/env sh
set -eu
unset NO_COLOR
project_root="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
tmp_pg_root=""
if [ -z "${PGDATA:-}" ] || [ -z "${PGHOST:-}" ]; then
  mkdir -p "$project_root/tmp"
  tmp_pg_root="$(mktemp -d "$project_root/tmp/adonisjs-template-pg-XXXXXX")"
fi
export PGDATA="${PGDATA:-$tmp_pg_root/.postgres}"
export PGHOST="${PGHOST:-$tmp_pg_root/.pgsocket}"
export PGPORT="${PGPORT:-5432}"
export PGUSER="${PGUSER:-postgres}"
export PGPASSWORD="${PGPASSWORD:-postgres}"
export PGDATABASE="${PGDATABASE:-adonisjs-template}"
export DB_HOST="${DB_HOST:-$PGHOST}"
export DB_PORT="${DB_PORT:-$PGPORT}"
export DB_USER="${DB_USER:-$PGUSER}"
export DB_PASSWORD="${DB_PASSWORD:-$PGPASSWORD}"
export DB_DATABASE="${DB_DATABASE:-$PGDATABASE}"
cleanup() {
  if npm run db:status >/dev/null 2>&1; then
    npm run db:stop
  fi
  if [ -n "$tmp_pg_root" ]; then
    rm -rf "$tmp_pg_root"
  fi
}
run_checks() {
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
}
status=0
run_checks || status=$?
cleanup
exit "$status"
