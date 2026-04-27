{
  pkgs ? import <nixpkgs> { },
}:
let
  pythonDeps = [
    pkgs.python313Packages.matplotlib
    pkgs.python313Packages.pandas
  ];
  pythonEnv = pkgs.python313.withPackages (_: pythonDeps);
  runtimeScript = pkgs.writeShellScript "python_latex_template" ''
    set -euo pipefail
    package_dir="$(cd "$(dirname "$0")/../$(basename "$0")" && pwd)"
    rm -rf tmp
    ${pythonEnv}/bin/python3 "$package_dir/main.py"
    cp "$package_dir"/ms.{tex,bib} tmp/
    ${pkgs.texliveFull}/bin/latexmk -cd -pdf tmp/ms.tex
  '';
in
pkgs.python313Packages.buildPythonPackage rec {
  installPhase = ''
    install -Dm644 ./main.py $out/${pname}/main.py
    install -Dm644 ./ms.tex $out/${pname}/ms.tex
    install -Dm644 ./ms.bib $out/${pname}/ms.bib
    install -Dm755 ${runtimeScript} $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = builtins.baseNameOf src;
  propagatedBuildInputs = pythonDeps;
  pyproject = false;
  src = ./.;
  version = "0.0.0";
}
