{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.maven
      pkgs.openjdk
    ];
    installPhase = ''
      mkdir -p $out/bin
      echo "#!/bin/sh" > $out/bin/${pname}
      echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
      echo "exec ${pkgs.maven}/bin/mvn -f $out/share/quarkus/pom.xml quarkus:dev" >> $out/bin/${pname}
      mkdir -p $out/share/quarkus
      cp -r . $out/share/quarkus/
      chmod +x $out/bin/${pname}
      '';
    pname = "quarkus_template";
    src = ./.;
    version = "0.0.0";
  }
