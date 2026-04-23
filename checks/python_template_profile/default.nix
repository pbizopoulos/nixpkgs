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
      pkgs.python312Packages.pyinstrument
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
    DEBUG=1 pyinstrument main.py
    touch "$out"
  ''
