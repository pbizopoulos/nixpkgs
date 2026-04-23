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
        _: inputs.self.packages.${pkgs.stdenv.system}.${packageName}.propagatedBuildInputs
      ))
      pkgs.python312Packages.pyinstrument
    ];
    src = ../../packages/${packageName};
  }
  ''
    export HOME="$PWD"
    cd "$src"
    DEBUG=1 pyinstrument main.py
    touch "$out"
  ''
