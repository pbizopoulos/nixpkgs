{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      (pkgs.odin)
    ];
    buildPhase = "HOME=$TMPDIR odin build . -out:${pname} -o:speed";
    installPhase = "mkdir -p $out/bin && cp ${pname} $out/bin/";
    pname = "odin_template";
    src = ./.;
    version = "0.0.0";
  }