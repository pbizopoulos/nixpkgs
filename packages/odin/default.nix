{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.odin ];
  buildPhase = "HOME=$TMPDIR odin build . -out:odin -o:speed";
  installPhase = "mkdir -p $out/bin && cp odin $out/bin/";
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
