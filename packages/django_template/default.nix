{
  pkgs ? import <nixpkgs> { },
}:
let
  launcher = pkgs.writeShellScript pname ''
    set -euo pipefail
    ${packageRootRuntimeEnvironment}
    script_name="''${0##*/}"
    mode="serve"
    if [ "$script_name" = "${pname}-manage" ]; then
      mode="manage"
    fi
    export PGPORT="''${PGPORT:-5432}"
    export PGUSER="''${PGUSER:-postgres}"
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
    export PORT="''${PORT:-8000}"
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
    export ALLOWED_HOSTS="''${ALLOWED_HOSTS:-127.0.0.1,localhost,[::1]}"
    export PGDATA="$state_root/.postgres"
    export PGHOST="$state_root/.pgsocket"
    export DATABASE_NAME="''${DATABASE_NAME:-${pname}}"
    export DB_PORT="$PGPORT"
    export DB_USER="$PGUSER"
    export DB_HOST="$PGHOST"
    start_db "$PGDATA/postgres.log"
    trap 'if run_pg pg_ctl -D "$PGDATA" status >/dev/null 2>&1; then run_pg pg_ctl -D "$PGDATA" stop >/dev/null 2>&1; fi' EXIT
    create_db >/dev/null 2>&1
    if [ "$mode" = "manage" ]; then
      exec python3 "$package_root/manage.py" "$@"
    fi
    export STATIC_ROOT="''${STATIC_ROOT:-$state_root/staticfiles}"
    export EMAIL_BACKEND="''${EMAIL_BACKEND:-django.core.mail.backends.console.EmailBackend}"
    python3 "$package_root/manage.py" migrate --noinput
    python3 "$package_root/manage.py" collectstatic --noinput >/dev/null
    exec gunicorn \
      --bind "127.0.0.1:$PORT" \
      --chdir "$package_root" \
      django_template.wsgi:application
  '';
  packageRootRuntimeEnvironment = ''
    export PATH="${
      pkgs.lib.makeBinPath [
        pkgs.coreutils
        pkgs.findutils
        pkgs.gnugrep
        pkgs.gnused
        pkgs.postgresql
        pythonWithDeps
      ]
    }:$PATH"
    package_root="@packageRoot@"
    export DJANGO_SETTINGS_MODULE="django_template.settings"
    export PYTHONPATH="$package_root''${PYTHONPATH:+:$PYTHONPATH}"
  '';
  pname = "django_template";
  pythonDeps = with pkgs.python313Packages; [
    django
    gunicorn
    psycopg
    whitenoise
  ];
  pythonWithDeps = pkgs.python313.withPackages (_: pythonDeps);
in
pkgs.python313Packages.buildPythonPackage rec {
  inherit pname;
  installPhase = ''
    mkdir -p "$out/lib/${pname}"
    cp -r ./. "$out/lib/${pname}"
    install -Dm755 ${launcher} "$out/bin/${pname}"
    substituteInPlace "$out/bin/${pname}" \
      --replace-fail "@packageRoot@" "$out/lib/${pname}"
    ln -s "${pname}" "$out/bin/${pname}-manage"
  '';
  meta.mainProgram = pname;
  propagatedBuildInputs = pythonDeps;
  pyproject = false;
  src = ./.;
  version = "0.0.0";
}
