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
          pkgs.python313Packages.pyinstrument
        ]
      ))
    ];
    src = ../../packages/${packageName};
  }
  ''
    export HOME="$PWD"
    export SECRET_KEY="django-insecure-template-secret-key"
    export DATABASE_ENGINE="sqlite"
    export DATABASE_NAME="$PWD/db.sqlite3"
    export EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend"
    workspace="$PWD/workspace"
    rm -rf "$workspace"
    mkdir -p "$workspace"
    cp -R --no-preserve=mode "$src"/. "$workspace"
    cd "$workspace"
    DEBUG=1 pyinstrument manage.py test
    touch "$out"
  ''
