{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  dontWrapPythonPrograms = true;
  installPhase = ''
    mkdir -p $out/bin
    cp ./main.py $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  propagatedBuildInputs = [ ];
  src = ./.;
  version = "0.0.0";
}
