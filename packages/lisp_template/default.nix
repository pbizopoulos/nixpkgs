{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      (pkgs.sbcl)
    ];
    installPhase = ''
      mkdir -p $out/bin
      cp main.lisp $out/bin/${pname}.lisp
      makeWrapper ${pkgs.sbcl}/bin/sbcl $out/bin/${pname} \
        --add-flags "--script $out/bin/${pname}.lisp"
      '';
    nativeBuildInputs = [
      (pkgs.makeWrapper)
    ];
    pname = "lisp_template";
    src = ./.;
    version = "0.0.0";
  }