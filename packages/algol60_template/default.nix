{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildPhase = ''
    marst main.al -o main.c
    cc main.c -lalgol -lm -o ${pname}
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin/
  '';
  nativeBuildInputs = [
    pkgs.gcc
    pkgs.marst
  ];
  pname = "algol60_template";
  src = ./.;
  version = "0.0.0";
}
