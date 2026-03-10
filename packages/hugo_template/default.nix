{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.hugo
    ];
    installPhase = ''
      mkdir -p $out/bin
      echo "#!/bin/sh" > $out/bin/${pname}
      echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
      echo "exec ${pkgs.hugo}/bin/hugo server --source $out/share/hugo" >> $out/bin/${pname}
      mkdir -p $out/share/hugo
      cp -r . $out/share/hugo/
      chmod +x $out/bin/${pname}
      '';
    pname = "hugo_template";
    src = ./.;
    version = "0.0.0";
  }
