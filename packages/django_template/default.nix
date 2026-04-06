{
  pkgs ? import <nixpkgs> { },
}:
let
  debugWrapper = pkgs.writeShellScript "${pname}-wrapper" ''
    set -euo pipefail
    package_root="@packageRoot@"
    export PATH="${runtimePath}:$PATH"
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
      export DATABASE_NAME="''${XDG_STATE_HOME:-/tmp}/${pname}/test.sqlite3"
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
  launcher = pkgs.writeShellScript pname ''
    set -euo pipefail
    ${packageRootRuntimeEnvironment}
    export HOST="''${HOST:-127.0.0.1}"
    export PORT="''${PORT:-8000}"
    export APP_NAME="''${APP_NAME:-Django Starter}"
    export SUPPORT_EMAIL="''${SUPPORT_EMAIL:-support@example.com}"
    export SECRET_KEY="''${SECRET_KEY:-django-insecure-template-secret-key}"
    export ALLOWED_HOSTS="''${ALLOWED_HOSTS:-$HOST,127.0.0.1,localhost,[::1]}"
    state_root="''${XDG_STATE_HOME:-/tmp}/${pname}"
    mkdir -p "$state_root"
    export DATABASE_NAME="''${DATABASE_NAME:-$state_root/${pname}.sqlite3}"
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
