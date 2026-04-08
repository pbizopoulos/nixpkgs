#!/usr/bin/env sh
set -eu
project_root="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
pgdata="${PGDATA:-$project_root/tmp/.postgres}"
pgsocket="${PGHOST:-$project_root/tmp/.pgsocket}"
pgport="${PGPORT:-5432}"
pguser="${PGUSER:-postgres}"
pgdatabase="${PGDATABASE:-adonisjs-template}"
logfile="$pgdata/postgres.log"
pgsystem_user=""
if [ "$(id -u)" -eq 0 ]; then
  for candidate in postgres nobody; do
    if id "$candidate" >/dev/null 2>&1; then
      pgsystem_user="$candidate"
      break
    fi
  done
  if [ -z "$pgsystem_user" ]; then
    echo "No unprivileged system user available" >&2
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
  mkdir -p "$pgdata" "$pgsocket"
  if [ -n "$pgsystem_user" ]; then
    chown -R "$pgsystem_user" "$pgdata" "$pgsocket"
  fi
  chmod 700 "$pgdata" "$pgsocket"
}
init_db() {
  prepare_pg_dirs
  if [ ! -f "$pgdata/PG_VERSION" ]; then
    run_pg initdb --username="$pguser" --auth=trust -D "$pgdata"
  fi
}
start_db() {
  init_db
  if run_pg pg_ctl -D "$pgdata" status >/dev/null 2>&1; then
    echo "Postgres already running"
    return
  fi
  run_pg pg_ctl -D "$pgdata" -l "$logfile" -o "-c listen_addresses='' -k '$pgsocket' -p '$pgport'" start
  run_pg pg_isready -h "$pgsocket" -p "$pgport" -U "$pguser" >/dev/null
}
stop_db() {
  if run_pg pg_ctl -D "$pgdata" status >/dev/null 2>&1; then
    run_pg pg_ctl -D "$pgdata" stop
  else
    echo "Postgres is not running"
  fi
}
create_db() {
  start_db
  if run_pg psql -h "$pgsocket" -p "$pgport" -U "$pguser" -d postgres -tAc \
    "select 1 from pg_database where datname = '$pgdatabase'" | grep -q 1; then
    echo "Database '$pgdatabase' already exists"
    return
  fi
  run_pg createdb -h "$pgsocket" -p "$pgport" -U "$pguser" "$pgdatabase"
}
case "${1:-}" in
init) init_db ;;
start) start_db ;;
stop) stop_db ;;
status) run_pg pg_ctl -D "$pgdata" status ;;
createdb) create_db ;;
reset)
  if run_pg pg_ctl -D "$pgdata" status >/dev/null 2>&1; then
    stop_db
  fi
  rm -rf "$pgdata" "$pgsocket"
  create_db
  ;;
*)
  echo "Usage: $0 {init|start|stop|status|createdb|reset}" >&2
  exit 1
  ;;
esac
