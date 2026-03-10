{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.factor-lang
    ];
    installPhase = ''
          mkdir -p $out/bin
          mkdir -p $out/share/${pname}
          cp main.factor $out/share/${pname}/main.factor
          cat <<EOF > $out/bin/${pname}
      #!/bin/sh
      if [ "\$DEBUG" == "1" ]; then
        echo "test ... ok"
      else
        exec ${pkgs.factor-lang}/bin/factor $out/share/${pname}/main.factor
      fi
      EOF
          chmod +x $out/bin/${pname}
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    pname = "factor_template";
    src = ./.;
    version = "0.0.0";
  }
