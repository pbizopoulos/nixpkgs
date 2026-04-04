{
  inputs,
  pkgs ? import <nixpkgs> { },
}:
let
  defaultEnvironment = ''
    export TZ="''${TZ:-UTC}"
    export NODE_ENV="''${NODE_ENV:-production}"
    export PORT="''${PORT:-3333}"
    export HOST="''${HOST:-localhost}"
    export LOG_LEVEL="''${LOG_LEVEL:-info}"
    export APP_NAME="''${APP_NAME:-AdonisJS Starter}"
    export APP_KEY="''${APP_KEY:-01234567890123456789012345678901}"
    export APP_URL="''${APP_URL:-http://$HOST:$PORT}"
    export SESSION_DRIVER="''${SESSION_DRIVER:-cookie}"
    export LIMITER_STORE="''${LIMITER_STORE:-memory}"
    export MAIL_MAILER="''${MAIL_MAILER:-smtp}"
    export MAIL_FROM_ADDRESS="''${MAIL_FROM_ADDRESS:-starter@example.com}"
    export MAIL_FROM_NAME="''${MAIL_FROM_NAME:-AdonisJS Starter}"
  '';
  installationScript = inputs.agenix-shell.lib.installationScript pkgs.stdenv.system {
    secrets.secrets.file = ../../secrets/secrets.age;
  };
  launcher = pkgs.writeShellScript pname ''
    set -euo pipefail
    ${packageRootRuntimeEnvironment}
    app_entrypoint="$package_root/lib/node_modules/${pname}/bin/entrypoint.js"
    migrate_helper="$package_root/bin/${pname}-migrate"
    pg_helper="$package_root/lib/node_modules/${pname}/bin/pg.sh"
    ${defaultEnvironment}
    has_database_config=0
    for key in DATABASE_URL DB_HOST DB_PORT DB_USER DB_PASSWORD DB_DATABASE DB_SSL PGDATA PGHOST PGPORT PGUSER PGPASSWORD PGDATABASE; do
      value="$(printenv "$key" || true)"
      if [ -n "$value" ]; then
        has_database_config=1
        break
      fi
    done
    if [ "''${DEBUG:-0}" = "1" ] || [ "$has_database_config" -eq 1 ]; then
      if [ "''${DEBUG:-0}" != "1" ]; then
        "$migrate_helper"
      fi
      exec ${pkgs.lib.getExe pkgs.nodejs} "$app_entrypoint" "$@"
    fi
    tmp_pg_root="$(mktemp -d /tmp/${pname}-pg-XXXXXX)"
    child_pid=""
    cleanup() {
      if [ -n "''${tmp_pg_root:-}" ] && [ -e "''${tmp_pg_root:-}" ]; then
        ${pkgs.bash}/bin/bash "$pg_helper" stop >/dev/null 2>&1 || true
        rm -rf "$tmp_pg_root"
      fi
    }
    forward_and_cleanup() {
      local signal="$1"
      trap - INT TERM
      if [ -n "''${child_pid:-}" ]; then
        kill -s "$signal" "$child_pid" 2>/dev/null || true
        wait "$child_pid" 2>/dev/null || true
      fi
      cleanup
      exit 0
    }
    trap 'forward_and_cleanup TERM' TERM
    trap 'forward_and_cleanup INT' INT
    export PGDATA="$tmp_pg_root/.postgres"
    export PGHOST="$tmp_pg_root/.pgsocket"
    export PGPORT="''${PGPORT:-5432}"
    export PGUSER="''${PGUSER:-postgres}"
    export PGPASSWORD="''${PGPASSWORD:-postgres}"
    export PGDATABASE="''${PGDATABASE:-${pname}}"
    export DB_HOST="$PGHOST"
    export DB_PORT="$PGPORT"
    export DB_USER="$PGUSER"
    export DB_PASSWORD="$PGPASSWORD"
    export DB_DATABASE="$PGDATABASE"
    export DB_SSL="''${DB_SSL:-false}"
    export DATABASE_URL="postgres://$PGUSER:$PGPASSWORD@/$PGDATABASE?host=$PGHOST&port=$PGPORT"
    ${pkgs.bash}/bin/bash "$pg_helper" start
    ${pkgs.bash}/bin/bash "$pg_helper" createdb
    "$migrate_helper"
    ${pkgs.lib.getExe pkgs.nodejs} "$app_entrypoint" "$@" &
    child_pid="$!"
    set +e
    wait "$child_pid"
    status="$?"
    set -e
    cleanup
    exit "$status"
  '';
  migrate = pkgs.writeShellScript "${pname}-migrate" ''
    set -euo pipefail
    ${packageRootRuntimeEnvironment}
    ${defaultEnvironment}
    exec ${pkgs.lib.getExe pkgs.nodejs} \
      "$package_root/lib/node_modules/${pname}/build/ace.js" \
      migration:run \
      --force
  '';
  packageRootRuntimeEnvironment = ''
    export PATH="${runtimePath}:$PATH"
    ${packageRootShellVariables}
  '';
  packageRootShellVariables = ''
    script_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
    package_root="$(dirname "$script_dir")"
  '';
  pname = "adonisjs-template";
  runtimePath = pkgs.lib.makeBinPath [
    pkgs.bash
    pkgs.nodejs
    pkgs.openssl
    pkgs.postgresql
  ];
in
pkgs.buildNpmPackage {
  inherit pname;
  dontNpmPrune = true;
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.nodejs
    pkgs.openssl
    pkgs.postgresql
  ];
  npmDepsHash = "sha256-3Nl9xg7cjxGfqOYEXU4/AWUT0IyJzNR4+hq724g6ZOg=";
  postInstall = ''
    cp -r build "$out/lib/node_modules/${pname}/build"
    mkdir -p "$out/lib/node_modules/${pname}/public"
    cp -r public/assets "$out/lib/node_modules/${pname}/public/assets"
    rm -f "$out/bin/${pname}"
    rm -f "$out/bin/${pname}-migrate"
    cp ${launcher} "$out/bin/${pname}"
    cp ${migrate} "$out/bin/${pname}-migrate"
  '';
  postPatch = ''
    substituteInPlace bin/entrypoint.js \
      --replace-fail "@packagedRuntimePath@" "${runtimePath}" \
      --replace-fail "@packagedPlaywrightBrowsersPath@" "${pkgs.playwright-driver.browsers}" \
      --replace-fail "@packagedChromiumExecutablePath@" "${pkgs.lib.getExe pkgs.chromium}"
  '';
  shellHook = ''
    # shellcheck disable=SC1091
    source ${pkgs.lib.getExe installationScript}
    export $(grep -v '^#' "$secrets_PATH" | xargs)
    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=${pkgs.lib.getExe pkgs.chromium}
    export PGDATA="''${PGDATA:-$PWD/tmp/.postgres}"
    export PGHOST="''${PGHOST:-$PWD/tmp/.pgsocket}"
    export PGPORT="''${PGPORT:-5432}"
    export PGUSER="''${PGUSER:-postgres}"
    export PGPASSWORD="''${PGPASSWORD:-postgres}"
    export PGDATABASE="''${PGDATABASE:-${pname}}"
    export DB_HOST="''${DB_HOST:-$PGHOST}"
    export DB_PORT="''${DB_PORT:-$PGPORT}"
    export DB_USER="''${DB_USER:-$PGUSER}"
    export DB_PASSWORD="''${DB_PASSWORD:-$PGPASSWORD}"
    export DB_DATABASE="''${DB_DATABASE:-$PGDATABASE}"
    export DB_SSL="''${DB_SSL:-false}"
    export DATABASE_URL="postgres://''${PGUSER}:''${PGPASSWORD}@/''${PGDATABASE}?host=''${PGHOST}&port=''${PGPORT}"
  '';
  src = ./.;
  version = "0.0.0";
}
