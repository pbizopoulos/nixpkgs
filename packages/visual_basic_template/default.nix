{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      echo "#!/bin/sh" > $out/bin/${pname}
      echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
      echo "echo 'Visual Basic template (source only)'" >> $out/bin/${pname}
      chmod +x $out/bin/${pname}
      '';
    pname = "visual_basic_template";
    src = ./.;
    version = "0.0.0";
  }
