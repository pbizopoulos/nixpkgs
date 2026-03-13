{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildPhase = ''
    clang -o ${pname} main.m -O3 -Wall -Wextra -Werror
  '';
  installPhase = ''
    install -Dm755 ${pname} $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.clang
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
