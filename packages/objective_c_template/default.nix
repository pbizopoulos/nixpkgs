{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildPhase = ''
    clang -o ${pname} main.m
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin/
  '';
  nativeBuildInputs = [
    pkgs.clang
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
