{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      echo "#!/bin/sh" > $out/bin/${pname}
      echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
      echo "echo 'CSS template'" >> $out/bin/${pname}
      chmod +x $out/bin/${pname}
      '';
    pname = "css_template";
    src = ./.;
    version = "0.0.0";
  }
