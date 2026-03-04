{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.nim ];
  buildPhase = "HOME=$TMPDIR nim c -o:nim main.nim";
  installPhase = "mkdir -p $out/bin && cp nim $out/bin/${pname}";
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
