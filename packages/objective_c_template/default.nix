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
  nativeBuildInputs = [
    pkgs.clang
  ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
