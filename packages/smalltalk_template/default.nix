{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.gnu-smalltalk
    ];
    installPhase = ''
          mkdir -p $out/bin
          cat <<EOF > $out/bin/${pname}
      #!/usr/bin/env bash
      ${pkgs.gnu-smalltalk}/bin/gst -q ${./.}/main.st
      EOF
          chmod 755 $out/bin/${pname}
      '';
    meta.mainProgram = pname;
    pname = "smalltalk_template";
    src = ./.;
    version = "0.0.0";
  }
