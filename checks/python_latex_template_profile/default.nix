{
  inputs,
  pkgs,
  ...
}:
let
  name = "python_latex_template";
in
pkgs.runCommand "${name}"
  {
    nativeBuildInputs = [
      (pkgs.python313.withPackages (
        _: inputs.self.packages.${pkgs.stdenv.system}.${name}.propagatedBuildInputs
      ))
      pkgs.python313Packages.pyinstrument
      pkgs.texliveFull
    ];
    src = ../../packages/${name};
  }
  ''
    export HOME="$PWD"
    export PYTHON_LATEX_TEMPLATE_ASSETS="$src"
    workspace="$PWD/workspace"
    rm -rf "$workspace"
    mkdir -p "$workspace"
    cp -R --no-preserve=mode "$src"/. "$workspace"
    cd "$workspace"
    DEBUG=1 pyinstrument main.py
    touch "$out"
  ''
