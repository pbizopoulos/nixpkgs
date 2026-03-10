{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      (pkgs.groovy)
      (pkgs.jdk)
    ];
    installPhase = ''
      mkdir -p $out/bin
      cp main.groovy $out/bin/${pname}.groovy
      makeWrapper ${pkgs.groovy}/bin/groovy $out/bin/${pname} \
        --add-flags "$out/bin/${pname}.groovy"
      '';
    nativeBuildInputs = [
      (pkgs.makeWrapper)
    ];
    pname = "groovy_template";
    src = ./.;
    version = "0.0.0";
  }