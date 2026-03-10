{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.gawk
    ];
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/awk && cp main.awk $out/share/awk/main.awk
      echo "#!/bin/sh" > $out/bin/${pname}
      echo "exec ${pkgs.gawk}/bin/awk -f $out/share/awk/main.awk" >> $out/bin/${pname}
      chmod +x $out/bin/${pname}
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    pname = "awk_template";
    src = ./.;
    version = "0.0.0";
  }
