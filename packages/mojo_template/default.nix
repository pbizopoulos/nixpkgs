{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      echo "#!/bin/sh" > $out/bin/${pname}
      echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
      echo "echo 'Mojo template (source only)'" >> $out/bin/${pname}
      chmod +x $out/bin/${pname}
      '';
    pname = "mojo_template";
    src = ./.;
    version = "0.0.0";
  }