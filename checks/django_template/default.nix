{
  inputs,
  pkgs,
  ...
}:
let
  name = builtins.baseNameOf ./.;
in
pkgs.runCommand "${name}"
  {
    nativeBuildInputs = [
      (pkgs.python313.withPackages (
        _:
        inputs.self.packages.${pkgs.stdenv.system}.${name}.propagatedBuildInputs
        ++ [
          pkgs.python313Packages.coverage
        ]
      ))
    ];
    src = ../../packages/${name};
  }
  ''
    export HOME="$PWD"
    export SECRET_KEY="django-insecure-template-secret-key"
    export DATABASE_ENGINE="sqlite"
    export EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend"
    coverage_root="$PWD/coverage"
    rm -rf "$coverage_root"
    mkdir -p "$coverage_root"
    export DATABASE_NAME="$coverage_root/db.sqlite3"
    export COVERAGE_FILE="$coverage_root/.coverage"
    cd "$src"
    DEBUG=1 coverage run --branch --source=starter,${name} "$src/manage.py" test
    coverage_percent=$(coverage report | awk '/^TOTAL/{print $4}')
    echo "coverage: $coverage_percent"
    touch "$out"
  ''
