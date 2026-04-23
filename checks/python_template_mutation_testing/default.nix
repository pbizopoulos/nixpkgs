{
  inputs,
  pkgs,
  ...
}:
let
  name = "python_template";
in
pkgs.runCommand "${name}"
  {
    nativeBuildInputs = [
      (pkgs.python312.withPackages (
        _: inputs.self.packages.${pkgs.stdenv.system}.${name}.propagatedBuildInputs
      ))
      inputs.self.packages.${pkgs.stdenv.system}.cosmic_ray
    ];
    src = ../../packages/${name};
  }
  ''
    export HOME="$PWD"
    workspace="$PWD/workspace"
    rm -rf "$workspace"
    mkdir -p "$workspace"
    cp -R --no-preserve=mode "$src"/. "$workspace"
    cd "$workspace"
    cat > cosmic-ray.toml <<'EOF'
    [cosmic-ray]
    module-path = "main.py"
    timeout = 10.0
    excluded-modules = []
    test-command = "DEBUG=1 python3 main.py"
    [cosmic-ray.distributor]
    name = "local"
    EOF
    cosmic-ray init cosmic-ray.toml cosmic-ray.sqlite
    cosmic-ray exec cosmic-ray.toml cosmic-ray.sqlite
    cr-report cosmic-ray.sqlite
    touch "$out"
  ''
