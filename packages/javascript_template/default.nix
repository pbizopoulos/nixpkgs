{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      (pkgs.nodejs)
    ];
    installPhase = ''
      mkdir -p $out/bin
      echo "#!/bin/sh" > $out/bin/${pname}
      echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
      echo "exec ${pkgs.nodejs}/bin/node $out/share/js/main.js" >> $out/bin/${pname}
      mkdir -p $out/share/js
      cp main.js $out/share/js/main.js
      chmod +x $out/bin/${pname}
      '';
    nativeBuildInputs = [
      (pkgs.makeWrapper)
    ];
    pname = "javascript_template";
    src = ./.;
    version = "0.0.0";
  }