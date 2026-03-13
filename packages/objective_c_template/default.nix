{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildPhase = ''
    clang -o ${pname} main.m -O3 -Wall -Wextra -Werror
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin/
  '';
  nativeBuildInputs = [
    pkgs.clang
  ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
