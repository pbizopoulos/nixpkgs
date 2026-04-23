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
      (pkgs.python313.withPackages (
        ps:
        inputs.self.packages.${pkgs.stdenv.system}.${name}.propagatedBuildInputs
        ++ [
          ps.coverage
        ]
      ))
      pkgs.texliveFull
    ];
    src = ../../packages/${name};
  }
  ''
    export HOME="$PWD"
    export PYTHON_LATEX_TEMPLATE_ASSETS="$src"
    DEBUG=1 coverage run --source="$src" "$src/main.py"
    coverage report
    touch "$out"
  ''
