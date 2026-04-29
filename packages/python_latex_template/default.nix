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
    script_dir="$(cd "$(dirname "$0")" && pwd)"
    rm -rf tmp
    ${pythonEnv}/bin/python3 "$script_dir/main.py"
    cp "$script_dir"/ms.{tex,bib} tmp/
    ${pkgs.texliveFull}/bin/latexmk -cd -pdf tmp/ms.tex
  '';
in
pkgs.python313Packages.buildPythonPackage rec {
  doInstallCheck = pkgs.stdenv.isLinux;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/${pname}"
    test -f "$PWD/tmp/ms.pdf"
    test -s "$PWD/tmp/ms.pdf"
    HOME="$(mktemp -d)" coverage erase
    HOME="$(mktemp -d)" DEBUG=1 coverage run --source="$src" "$src/main.py"
    HOME="$(mktemp -d)" coverage run --append --source="$src" "$src/main.py"
    coverage report --fail-under=100
    HOME="$(mktemp -d)" DEBUG=1 PYTHONWARNINGS=error pyinstrument "$src/main.py"
    runHook postInstallCheck
  '';
  installPhase = ''
    install -Dm644 ./main.py $out/bin/main.py
    install -Dm644 ./ms.tex $out/bin/ms.tex
    install -Dm644 ./ms.bib $out/bin/ms.bib
    install -Dm755 ${runtimeScript} $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  nativeInstallCheckInputs = [
    pkgs.python313Packages.coverage
    pkgs.python313Packages.pyinstrument
    pkgs.texliveFull
  ];
  pname = builtins.baseNameOf src;
  propagatedBuildInputs = pythonDeps;
  pyproject = false;
  src = ./.;
  version = "0.0.0";
}
