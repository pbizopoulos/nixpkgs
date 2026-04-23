{
  inputs,
  pkgs,
  ...
}:
let
  checkName = builtins.baseNameOf ./.;
  packageName = "django_template";
in
pkgs.runCommand "${checkName}"
  {
    nativeBuildInputs = [
      (pkgs.python313.withPackages (
        _:
        inputs.self.packages.${pkgs.stdenv.system}.${packageName}.propagatedBuildInputs
        ++ [
          pkgs.python313Packages.coverage
        ]
      ))
    ];
    src = ../../packages/${packageName};
  }
  ''
    export SECRET_KEY="django-insecure-template-secret-key"
    export DATABASE_ENGINE="sqlite"
    export EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend"
    coverage_root="$PWD/coverage"
    rm -rf "$coverage_root"
    mkdir -p "$coverage_root/html"
    export DATABASE_NAME="$coverage_root/db.sqlite3"
    export COVERAGE_FILE="$coverage_root/.coverage"
    cd "$src"
    DEBUG=1 coverage run --branch --source=starter,${packageName} "$src/manage.py" test
    coverage html --directory "$coverage_root/html"
    coverage report | tee "$coverage_root/summary.txt"
    touch "$out"
  ''
