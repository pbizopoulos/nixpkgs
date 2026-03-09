{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.ldc ];
  buildPhase = "ldc2 main.d -of=d";
  installPhase = "mkdir -p $out/bin && cp d $out/bin/${pname}";
  pname = "d_template";
  src = ./.;
  version = "0.0.0";
}
