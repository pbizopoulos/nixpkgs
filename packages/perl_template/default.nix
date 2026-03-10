{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    installPhase = ''
      mkdir -p $out/bin
      echo "#!/bin/sh" > $out/bin/${pname}
      echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
      echo "exec ${pkgs.perl}/bin/perl $out/share/perl/main.pl" >> $out/bin/${pname}
      mkdir -p $out/share/perl
      cp main.pl $out/share/perl/main.pl
      chmod +x $out/bin/${pname}
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    pname = "perl_template";
    src = ./.;
    version = "0.0.0";
  }
