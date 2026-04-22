{
  inputs,
  pkgs,
  ...
}:
let
  coverageScript = pkgs.writeShellScript "${name}-coverage" ''
    set -euo pipefail
    export HOME="$PWD"
    export PATH="${
      pkgs.lib.makeBinPath [
        pkgs.coreutils
        pkgs.findutils
        pkgs.gnugrep
        pkgs.gnused
        pythonWithDeps
      ]
    }:$PATH"
    export DJANGO_SETTINGS_MODULE="django_template.settings"
    export PYTHONPATH="${sourceRoot}''${PYTHONPATH:+:$PYTHONPATH}"
    export SECRET_KEY="django-insecure-template-secret-key"
    export DATABASE_ENGINE="sqlite"
    coverage_root="$PWD/coverage"
    rm -rf "$coverage_root"
    mkdir -p "$coverage_root"
    export DATABASE_NAME="$coverage_root/db.sqlite3"
    export EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend"
    export ALLOWED_HOSTS="testserver,localhost,127.0.0.1,[::1]"
    export COVERAGE_FILE="$coverage_root/.coverage"
    cd "${sourceRoot}"
    DEBUG=1 python3 -m coverage erase
    DEBUG=1 python3 -m coverage run --branch --source=starter,django_template manage.py test
    python3 -m coverage html -d "$coverage_root/html"
    coverage_report="$(python3 -m coverage report --fail-under=75)"
    printf '%s\n' "$coverage_report" | tee "$coverage_root/summary.txt"
    coverage_percent="$(printf '%s\n' "$coverage_report" | awk '/^TOTAL/{print $4}')"
    echo "coverage: $coverage_percent"
  '';
  name = builtins.baseNameOf ./.;
  package = inputs.self.packages.${pkgs.stdenv.system}.${name};
  pythonWithDeps = pkgs.python313.withPackages (
    ps:
    package.propagatedBuildInputs
    ++ [
      ps.coverage
    ]
  );
  sourceRoot = "${package}/lib/${name}";
in
pkgs.testers.runNixOSTest rec {
  name = "django_template";
  nodes.machine.environment.systemPackages = [
    package
    pkgs.curl
  ];
  testScript = ''
    machine.succeed("timeout 120 bash -lc 'nohup ${name} >/tmp/${name}.log 2>&1 &'")
    machine.succeed("timeout 120 bash -lc 'until ss -ltn | grep -q :8000; do sleep 1; done'")
    machine.succeed("timeout 120 bash -lc 'until curl -fsS http://127.0.0.1:8000/health; do sleep 1; done'")
    machine.succeed("${coverageScript}")
  '';
}
