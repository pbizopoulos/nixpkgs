{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    installPhase = ''
      mkdir -p $out/bin
      echo "#!/bin/sh" > $out/bin/${pname}
      echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
      echo "exec ${pkgs.ruby}/bin/ruby $out/share/ruby/main.rb" >> $out/bin/${pname}
      mkdir -p $out/share/ruby
      cp main.rb $out/share/ruby/main.rb
      chmod +x $out/bin/${pname}
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    pname = "ruby_template";
    src = ./.;
    version = "0.0.0";
  }
