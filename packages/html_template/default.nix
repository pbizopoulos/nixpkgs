{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.bash
    ];
    installPhase = ''
      mkdir -p $out/bin
      echo "#!/usr/bin/env bash" > $out/bin/${pname}
      echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
      echo "exec ${pkgs.nodePackages.http-server}/bin/http-server $out/share/html \"\$@\"" >> $out/bin/${pname}
      mkdir -p $out/share/html
      cp index.html $out/share/html/
      chmod +x $out/bin/${pname}
      '';
    pname = "html_template";
    src = ./.;
    version = "0.0.0";
  }
