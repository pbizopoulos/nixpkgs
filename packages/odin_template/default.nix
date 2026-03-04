{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.odin ];
  buildPhase = "HOME=$TMPDIR odin build . -out:${pname} -o:speed";
  installPhase = "mkdir -p $out/bin && cp ${pname} $out/bin/";
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
