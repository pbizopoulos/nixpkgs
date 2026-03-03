{
  pkgs ? import <nixpkgs> { },
}:
pkgs.python313Packages.buildPythonPackage rec {
  installPhase = ''
    mkdir -p $out/bin
    cp ./main.py $out/bin/${pname}
    cp -r ./prm/ $out/bin/
  '';
  meta.mainProgram = pname;
  pname = builtins.baseNameOf src;
  propagatedBuildInputs = [
    pkgs.python313Packages.fire
    pkgs.python313Packages.libcst
  ];
  pyproject = false;
  src = ./.;
  version = "0.0.0";
}
