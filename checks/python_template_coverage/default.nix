{
  inputs,
  pkgs,
  ...
}:
let
  checkName = builtins.baseNameOf ./.;
  packageName = "python_template";
in
pkgs.runCommand "${checkName}"
  {
    nativeBuildInputs = [
      (pkgs.python312.withPackages (
        _:
        inputs.self.packages.${pkgs.stdenv.system}.${packageName}.propagatedBuildInputs
        ++ [
          pkgs.python312Packages.coverage
        ]
      ))
    ];
    src = ../../packages/${packageName};
  }
  ''
    export HOME="$PWD"
    DEBUG=1 coverage run --source="$src" "$src/main.py"
    coverage report
    touch "$out"
  ''
