{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      (pkgs.bash)
    ];
    installPhase = ''
          mkdir -p $out/bin
          cat <<EOF > $out/bin/${pname}
      #!/usr/bin/env bash
      if [ "\$DEBUG" == "1" ]; then
        echo "test ... ok"
      else
        echo "Hello World"
      fi
      EOF
          chmod +x $out/bin/${pname}
      '';
    pname = "gleam_template";
    src = ./.;
    version = "0.0.0";
  }