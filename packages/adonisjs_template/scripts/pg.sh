#!/usr/bin/env sh
set -eu
project_root="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
pgdata="${PGDATA:-$project_root/tmp/.postgres}"
pgsocket="${PGHOST:-/tmp/adonisjs-template-pg}"
pgport="${PGPORT:-5432}"
pguser="${PGUSER:-postgres}"
pgpassword="${PGPASSWORD:-postgres}"
pgdatabase="${PGDATABASE:-postgres}"
logfile="$pgdata/postgres.log"
export PGDATA="$pgdata"
export PGHOST="$pgsocket"
export PGPORT="$pgport"
export PGUSER="$pguser"
export PGPASSWORD="$pgpassword"
export PGDATABASE="$pgdatabase"
pgsystem_user=""
if [ "$(id -u)" -eq 0 ]; then
  for candidate in "${PGSYSTEM_USER:-postgres}" nobody; do
    if id "$candidate" >/dev/null 2>&1; then
      pgsystem_user="$candidate"
      break
    fi
  done
  if [ -z "$pgsystem_user" ]; then
    echo "No unprivileged system user available to run Postgres" >&2
    exit 1
  fi
fi
shell_quote() {
  printf "'%s'" "$(printf "%s" "$1" | sed "s/'/'\\\\''/g")"
}
run_pg() {
  if [ -z "$pgsystem_user" ]; then
    "$@"
    return
  fi
  path_prefix="PATH=$(shell_quote "${PATH:-}")"
  cmd=""
  for arg in "$@"; do
    quoted_arg="$(shell_quote "$arg")"
    if [ -z "$cmd" ]; then
      cmd="$quoted_arg"
    else
      cmd="$cmd $quoted_arg"
    fi
  done
  su -s /bin/sh "$pgsystem_user" -c "$path_prefix; export PATH; $cmd"
}
prepare_pg_dirs() {
  mkdir -p "$PGDATA" "$PGHOST"
  if [ -n "$pgsystem_user" ]; then
    chown -R "$pgsystem_user" "$PGDATA" "$PGHOST"
    chmod 700 "$PGDATA" "$PGHOST"
  fi
}
init_db() {
  prepare_pg_dirs
  if [ ! -f "$PGDATA/PG_VERSION" ]; then
    run_pg initdb \
      --username="$PGUSER" \
      --auth=trust \
      -D "$PGDATA"
  fi
}
start_db() {
  init_db
  if run_pg pg_ctl -D "$PGDATA" status >/dev/null 2>&1; then
    echo "Postgres already running"
    return
  fi
  run_pg pg_ctl \
    -D "$PGDATA" \
    -l "$logfile" \
    -o "-k '$PGHOST' -p '$PGPORT'" \
    start
  run_pg pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" >/dev/null
}
stop_db() {
  if run_pg pg_ctl -D "$PGDATA" status >/dev/null 2>&1; then
    run_pg pg_ctl -D "$PGDATA" stop
  else
    echo "Postgres is not running"
  fi
}
create_db() {
  start_db
  if run_pg psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -tAc \
    "select 1 from pg_database where datname = '$PGDATABASE'" | grep -q 1; then
    echo "Database '$PGDATABASE' already exists"
    return
  fi
  run_pg createdb -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "$PGDATABASE"
}
reset_db() {
  stop_db || true
  rm -rf "$PGDATA" "$PGHOST"
  init_db
  start_db
  create_db
}
status_db() {
  run_pg pg_ctl -D "$PGDATA" status
  printf 'Socket: %s/.s.PGSQL.%s\n' "$PGHOST" "$PGPORT"
  printf 'Database: %s\n' "$PGDATABASE"
}
case "${1:-}" in
init)
  init_db
  ;;
start)
  start_db
  ;;
stop)
  stop_db
  ;;
status)
  status_db
  ;;
createdb)
  create_db
  ;;
reset)
  reset_db
  ;;
*)
  echo "Usage: $0 {init|start|stop|status|createdb|reset}" >&2
  exit 1
  ;;
esac
