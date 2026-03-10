{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.fpc
    ];
    buildPhase = ''
      fpc main.pas -o${pname}
      '';
    installPhase = ''
      mkdir -p $out/bin
      cp -f ${pname} $out/bin/
      chmod 755 $out/bin/${pname}
      '';
    meta.mainProgram = pname;
    pname = "delphi_template";
    src = ./.;
    version = "0.0.0";
  }
