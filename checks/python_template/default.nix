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
      (pkgs.python312.withPackages (
        _:
        inputs.self.packages.${pkgs.stdenv.system}.${name}.propagatedBuildInputs
        ++ [
          pkgs.python312Packages.coverage
        ]
      ))
    ];
    src = ../../packages/${name};
  }
  ''
    export HOME="$PWD"
    DEBUG=1 coverage run --source="$src" "$src/main.py"
    coverage report
    touch "$out"
  ''
