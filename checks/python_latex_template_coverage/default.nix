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
        _:
        inputs.self.packages.${pkgs.stdenv.system}.${name}.propagatedBuildInputs
        ++ [
          pkgs.python313Packages.coverage
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
