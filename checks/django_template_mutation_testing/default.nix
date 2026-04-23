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
        _: inputs.self.packages.${pkgs.stdenv.system}.${packageName}.propagatedBuildInputs
      ))
      inputs.self.packages.${pkgs.stdenv.system}.cosmic_ray
    ];
    src = ../../packages/${packageName};
  }
  ''
    export HOME="$PWD"
    export SECRET_KEY="django-insecure-template-secret-key"
    export DATABASE_ENGINE="sqlite"
    export DATABASE_NAME="$PWD/tmp/db.sqlite3"
    export EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend"
    workspace="$PWD/workspace"
    rm -rf "$workspace"
    mkdir -p "$workspace/tmp"
    cp -R --no-preserve=mode "$src"/. "$workspace"
    cd "$workspace"
    cat > cosmic-ray.toml <<'EOF'
    [cosmic-ray]
    module-path = ["manage.py", "django_template", "starter"]
    timeout = 10.0
    excluded-modules = ["**/tests/**"]
    test-command = "DEBUG=1 python3 manage.py test"
    [cosmic-ray.distributor]
    name = "local"
    EOF
    cosmic-ray init cosmic-ray.toml cosmic-ray.sqlite
    cosmic-ray exec cosmic-ray.toml cosmic-ray.sqlite
    cr-report cosmic-ray.sqlite
    touch "$out"
  ''
