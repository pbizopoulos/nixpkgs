#!/usr/bin/env sh
set -eu
project_root="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
env_file="$project_root/.env"
if [ -f "$env_file" ]; then
  exit 0
fi
tz="${TZ:-UTC}"
node_env="${NODE_ENV:-development}"
port="${PORT:-3333}"
host="${HOST:-localhost}"
log_level="${LOG_LEVEL:-info}"
app_name="${APP_NAME:-AdonisJS Starter}"
app_key="${APP_KEY:-development-app-key-development-app-key}"
app_url="${APP_URL:-http://$host:$port}"
db_host="${DB_HOST:-${PGHOST:-127.0.0.1}}"
db_port="${DB_PORT:-${PGPORT:-5432}}"
db_user="${DB_USER:-postgres}"
db_password="${DB_PASSWORD:-postgres}"
db_database="${DB_DATABASE:-adonisjs_template}"
db_ssl="${DB_SSL:-false}"
cat >"$env_file" <<EOF
TZ=$tz
NODE_ENV=$node_env
PORT=$port
HOST=$host
LOG_LEVEL=$log_level
APP_NAME=$app_name
APP_KEY=$app_key
APP_URL=$app_url
DB_HOST=$db_host
DB_PORT=$db_port
DB_USER=$db_user
DB_PASSWORD=$db_password
DB_DATABASE=$db_database
DB_SSL=$db_ssl
EOF
