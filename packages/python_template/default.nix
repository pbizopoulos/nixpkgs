{
  pkgs ? import <nixpkgs> { },
}:
pkgs.python312Packages.buildPythonPackage rec {
  installPhase = ''
    mkdir -p $out/bin
    cp ./main.py $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = builtins.baseNameOf src;
  pyproject = false;
  src = ./.;
  version = "0.0.0";
}
