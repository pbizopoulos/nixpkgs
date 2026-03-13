{
  pkgs ? import <nixpkgs> { },
}:
pkgs.python3Packages.buildPythonPackage rec {
  installPhase = ''
    mkdir -p $out/bin
    cp ./main.py $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  propagatedBuildInputs = [
    pkgs.python3Packages.termcolor
  ];
  pyproject = false;
  src = ./.;
  version = "0.0.0";
}
