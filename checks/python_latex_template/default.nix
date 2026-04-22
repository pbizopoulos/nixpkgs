{
  inputs,
  pkgs,
  ...
}:
let
  name = builtins.baseNameOf ./.;
  package = inputs.self.packages.${pkgs.stdenv.system}.${name};
in
pkgs.runCommand "${name}"
  {
    nativeBuildInputs = [
      (pkgs.python313.withPackages (
        ps:
        package.propagatedBuildInputs
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
    coverage_percent=$(coverage report | awk '/^TOTAL/{print $4}')
    echo "coverage: $coverage_percent"
    touch "$out"
  ''
