{
  pkgs ? import <nixpkgs> { },
}:
let
  packageName = builtins.baseNameOf ./.;
  pythonDeps = [
    pkgs.python313Packages.matplotlib
    pkgs.python313Packages.pandas
  ];
  pythonEnv = pkgs.python313.withPackages (_: pythonDeps);
  runtimeScript = pkgs.writeShellScript "python_latex_template" ''
    set -euo pipefail
    script_dir="$(cd "$(dirname "$0")" && pwd)"
    package_root="$(cd "$script_dir/.." && pwd)"
    destination_root="$PWD"
    cd "$destination_root"
    rm -rf tmp
    ${pythonEnv}/bin/python3 "$package_root/${packageName}/main.py"
    cp "$package_root/${packageName}/ms.tex" tmp/ms.tex
    cp "$package_root/${packageName}/ms.bib" tmp/ms.bib
    cd tmp
    ${pkgs.texliveFull}/bin/latexmk -pdf ms.tex >/dev/null 2>&1
  '';
in
pkgs.python313Packages.buildPythonPackage rec {
  installPhase = ''
    mkdir -p $out/bin
    install -Dm644 ./main.py $out/${packageName}/main.py
    install -Dm644 ./ms.tex $out/${packageName}/ms.tex
    install -Dm644 ./ms.bib $out/${packageName}/ms.bib
    install -Dm755 ${runtimeScript} $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = packageName;
  propagatedBuildInputs = pythonDeps;
  pyproject = false;
  src = ./.;
  version = "0.0.0";
}
