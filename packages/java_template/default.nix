{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.jdk
    ];
    buildPhase = "javac src/main/java/Main.java -d .";
    installPhase = ''
      mkdir -p $out/share/java
      cp Main.class $out/share/java/
      mkdir -p $out/bin
      makeWrapper ${pkgs.jdk}/bin/java $out/bin/${pname} \
        --add-flags "-cp $out/share/java Main"
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    pname = "java_template";
    src = ./.;
    version = "0.0.0";
  }
