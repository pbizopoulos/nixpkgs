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
    workspace="$PWD/workspace"
    rm -rf "$workspace"
    mkdir -p "$workspace"
    cp -R --no-preserve=mode "$src"/. "$workspace"
    cd "$workspace"
    DEBUG=1 pyinstrument main.py
    touch "$out"
  ''
