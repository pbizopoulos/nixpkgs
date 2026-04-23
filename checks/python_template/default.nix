{
  inputs,
  pkgs,
  ...
}:
let
  name = builtins.baseNameOf ./.;
  package = inputs.self.packages.${pkgs.stdenv.system}.${name};
  cosmicRay = inputs.self.packages.${pkgs.stdenv.system}.cosmic_ray;
in
pkgs.runCommand "${name}"
  {
    nativeBuildInputs = [
      (pkgs.python312.withPackages (
        _:
        package.propagatedBuildInputs
        ++ [
          pkgs.python312Packages.coverage
        ]
      ))
      cosmicRay
    ];
    src = ../../packages/${name};
  }
  ''
    export HOME="$PWD"
    workspace="$PWD/workspace"
    coverage_root="$workspace/coverage"
    config_file="$workspace/cosmic-ray.toml"
    session_file="$workspace/cosmic-ray.sqlite"
    rm -rf "$workspace"
    mkdir -p "$workspace" "$coverage_root"
    cp -r "$src"/. "$workspace"
    cd "$workspace"
    DEBUG=1 coverage run --source=. main.py
    coverage report
    cat > "$config_file" <<'EOF'
        [cosmic-ray]
        module-path = "main.py"
        timeout = 10.0
        excluded-modules = []
        test-command = "DEBUG=1 python3 main.py"
        [cosmic-ray.distributor]
        name = "local"
    EOF
    cosmic-ray init "$config_file" "$session_file"
    cosmic-ray exec "$config_file" "$session_file"
    cr-report "$session_file"
    touch "$out"
  ''
