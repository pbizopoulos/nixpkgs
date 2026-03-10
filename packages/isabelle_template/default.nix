{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      (pkgs.isabelle)
    ];
    buildPhase = ''
      export HOME=$TMPDIR
      isabelle build -D .
      '';
    installPhase = ''
          mkdir -p $out/bin
          cat <<EOF > $out/bin/${pname}
      #!/usr/bin/env bash
      echo "Isabelle session built successfully"
      EOF
          chmod +x $out/bin/${pname}
      '';
    pname = "isabelle_template";
    src = ./.;
    version = "0.0.0";
  }