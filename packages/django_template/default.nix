{
  pkgs ? import <nixpkgs> { },
}:
let
  debugWrapper = pkgs.writeShellScript "${pname}-wrapper" ''
    set -euo pipefail
    package_root="@packageRoot@"
    export PATH="${runtimePath}:$PATH"
    ${postgresBootstrapFunctions}
    start_temp_postgres() {
      start_db "$PGDATA/postgres.log"
      create_db >/dev/null 2>&1
    }
    resolve_source_root() {
      local candidate
      local current_dir="$PWD"
      if [ -n "''${CANONICALIZATION_ROOT:-}" ]; then
        candidate="$CANONICALIZATION_ROOT/packages/${pname}"
        if [ -f "$candidate/manage.py" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi
      fi
      while [ "$current_dir" != "/" ]; do
        candidate="$current_dir/packages/${pname}"
        if [ -f "$candidate/manage.py" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi
        current_dir="$(dirname "$current_dir")"
      done
      if [ -f "$PWD/manage.py" ]; then
        printf '%s\n' "$PWD"
        return 0
      fi
      return 1
    }
    if [ "''${DEBUG:-0}" = "1" ]; then
      coverage_root=""
      if source_root="$(resolve_source_root)"; then
        coverage_root="$source_root/tmp/coverage"
      else
        source_root="$package_root"
        coverage_root="''${XDG_STATE_HOME:-/tmp}/${pname}/coverage"
      fi
      rm -rf "$coverage_root"
      mkdir -p "$coverage_root"
      cd "$source_root"
      export DJANGO_SETTINGS_MODULE="django_template.settings"
      export PYTHONPATH="$source_root''${PYTHONPATH:+:$PYTHONPATH}"
      export SECRET_KEY="django-insecure-template-secret-key"
      ${defaultPostgresEnvironment}
      export PGDATA="$coverage_root/.postgres"
      export PGHOST="$(mktemp -d "/tmp/${pname}-pgsocket.XXXXXX")"
      export DATABASE_NAME="''${DATABASE_NAME:-${pname}}"
      export DB_PORT="$PGPORT"
      export DB_USER="$PGUSER"
      export DB_PASSWORD="$PGPASSWORD"
      export DB_HOST="$PGHOST"
      start_temp_postgres
      trap 'run_pg pg_ctl -D "$PGDATA" stop >/dev/null 2>&1 || true; rm -rf "$PGHOST"' EXIT
      export EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend"
      export ALLOWED_HOSTS="testserver,localhost,127.0.0.1,[::1]"
      export COVERAGE_FILE="$coverage_root/.coverage"
      python3 -m coverage erase
      DEBUG=1 python3 -m coverage run --branch --source=starter,django_template manage.py test
      python3 -m coverage html -d "$coverage_root/html"
      python3 -m coverage report --fail-under=75 | tee "$coverage_root/summary.txt"
      exit 0
    fi
    exec "@launcher@" "$@"
  '';
  defaultPostgresEnvironment = ''
    export DATABASE_ENGINE="''${DATABASE_ENGINE:-postgresql}"
    export PGPORT="''${PGPORT:-5432}"
    export PGUSER="''${PGUSER:-postgres}"
    export PGPASSWORD="''${PGPASSWORD:-postgres}"
  '';
  launcher = pkgs.writeShellScript pname ''
    set -euo pipefail
    ${packageRootRuntimeEnvironment}
    ${defaultPostgresEnvironment}
    ${postgresBootstrapFunctions}
    export HOST="''${HOST:-127.0.0.1}"
    export PORT="''${PORT:-8000}"
    export APP_NAME="''${APP_NAME:-Django Starter}"
    export SUPPORT_EMAIL="''${SUPPORT_EMAIL:-support@example.com}"
    state_root="''${XDG_STATE_HOME:-/tmp}/${pname}"
    mkdir -p "$state_root"
    if [ -z "''${SECRET_KEY:-}" ]; then
      secret_key_file="$state_root/secret_key"
      if [ -f "$secret_key_file" ]; then
        export SECRET_KEY="$(cat "$secret_key_file")"
      else
        umask 077
        export SECRET_KEY="$(head -c 32 /dev/urandom | base64 | tr -d '\n')"
        printf '%s\n' "$SECRET_KEY" > "$secret_key_file"
      fi
    fi
    export ALLOWED_HOSTS="''${ALLOWED_HOSTS:-$HOST,127.0.0.1,localhost,[::1]}"
    has_database_config=0
    for key in DATABASE_URL DB_HOST DB_PORT DB_USER DB_PASSWORD DB_DATABASE DATABASE_NAME PGDATA PGHOST PGDATABASE; do
      value="''${!key-}"
      if [ -n "$value" ]; then
        has_database_config=1
        break
      fi
    done
    if [ "$has_database_config" -eq 0 ]; then
      export PGDATA="$state_root/.postgres"
      export PGHOST="$state_root/.pgsocket"
      export DATABASE_NAME="''${DATABASE_NAME:-${pname}}"
      export DB_PORT="$PGPORT"
      export DB_USER="$PGUSER"
      export DB_PASSWORD="$PGPASSWORD"
      export DB_HOST="$PGHOST"
      start_db "$PGDATA/postgres.log"
      trap 'run_pg pg_ctl -D "$PGDATA" stop >/dev/null 2>&1 || true' EXIT
      create_db >/dev/null 2>&1
    fi
    export STATIC_ROOT="''${STATIC_ROOT:-$state_root/staticfiles}"
    export EMAIL_BACKEND="''${EMAIL_BACKEND:-django.core.mail.backends.console.EmailBackend}"
    python3 "$package_root/manage.py" migrate --noinput
    python3 "$package_root/manage.py" collectstatic --noinput >/dev/null
    exec gunicorn \
      --bind "$HOST:$PORT" \
      --chdir "$package_root" \
      django_template.wsgi:application
  '';
  manage = pkgs.writeShellScript "${pname}-manage" ''
    set -euo pipefail
    ${packageRootRuntimeEnvironment}
    exec python3 "$package_root/manage.py" "$@"
  '';
  packageRootRuntimeEnvironment = ''
    export PATH="${runtimePath}:$PATH"
    package_root="@packageRoot@"
    export DJANGO_SETTINGS_MODULE="django_template.settings"
    export PYTHONPATH="$package_root''${PYTHONPATH:+:$PYTHONPATH}"
  '';
  pname = "django_template";
  postgresBootstrapFunctions = ''
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
    run_pg() {
      if [ -z "$pgsystem_user" ]; then
        "$@"
        return
      fi
      env PATH="$PATH" su -s /bin/sh -c '
        export PATH="$1"
        shift
        exec "$@"
      ' "$pgsystem_user" -- sh "$PATH" "$@"
    }
    prepare_pg_dirs() {
      mkdir -p "$PGDATA" "$PGHOST"
      if [ -n "$pgsystem_user" ]; then
        chown -R "$pgsystem_user" "$PGDATA" "$PGHOST"
      fi
      chmod 700 "$PGDATA" "$PGHOST"
    }
    init_db() {
      prepare_pg_dirs
      export PGUSER="''${PGUSER:-''${DB_USER:-postgres}}"
      export PGPORT="''${PGPORT:-''${DB_PORT:-5432}}"
      export PGDATABASE="''${PGDATABASE:-$DATABASE_NAME}"
      if [ ! -f "$PGDATA/PG_VERSION" ]; then
        run_pg initdb --username="$PGUSER" --auth=trust -D "$PGDATA" >/dev/null
      fi
    }
    start_db() {
      init_db
      if run_pg pg_ctl -D "$PGDATA" status >/dev/null 2>&1; then
        return
      fi
      run_pg pg_ctl -D "$PGDATA" -l "$1" -o "-k '$PGHOST' -p '$PGPORT'" start >/dev/null
      run_pg pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" >/dev/null
    }
    create_db() {
      run_pg psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -tAc \
        "select 1 from pg_database where datname = '$PGDATABASE'" | grep -q 1 && return
      run_pg createdb -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "$PGDATABASE"
    }
  '';
  python = pkgs.python313.withPackages (ps: [
    ps.coverage
    ps.django
    ps.gunicorn
    ps.psycopg
    ps.whitenoise
  ]);
  runtimePath = pkgs.lib.makeBinPath [
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnugrep
    pkgs.gnused
    pkgs.postgresql
    python
  ];
in
pkgs.stdenvNoCC.mkDerivation {
  inherit pname;
  installPhase = ''
    mkdir -p "$out/lib/${pname}"
    cp -r ./. "$out/lib/${pname}"
    install -Dm755 ${launcher} "$out/bin/.${pname}-launcher"
    install -Dm755 ${manage} "$out/bin/${pname}-manage"
    install -Dm755 ${debugWrapper} "$out/bin/${pname}"
    substituteInPlace "$out/bin/.${pname}-launcher" \
      --replace-fail "@packageRoot@" "$out/lib/${pname}"
    substituteInPlace "$out/bin/${pname}-manage" \
      --replace-fail "@packageRoot@" "$out/lib/${pname}"
    substituteInPlace "$out/bin/${pname}" \
      --replace-fail "@packageRoot@" "$out/lib/${pname}" \
      --replace-fail "@launcher@" "$out/bin/.${pname}-launcher"
  '';
  meta.mainProgram = pname;
  src = ./.;
  version = "0.0.0";
}
