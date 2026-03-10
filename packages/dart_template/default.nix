{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      (pkgs.dart)
    ];
    installPhase = ''
      mkdir -p $out/lib/dart
      cp main.dart pubspec.yaml $out/lib/dart/
      mkdir -p $out/bin
      makeWrapper ${pkgs.dart}/bin/dart $out/bin/${pname} \
        --add-flags "$out/lib/dart/main.dart"
      '';
    nativeBuildInputs = [
      (pkgs.makeWrapper)
    ];
    pname = "dart_template";
    src = ./.;
    version = "0.0.0";
  }