{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.guile
    ];
    installPhase = ''
          mkdir -p $out/bin
          cat <<EOF > $out/bin/${pname}
      #!/usr/bin/env bash
      ${pkgs.guile}/bin/guile -s ${./.}/main.scm
      EOF
          chmod 755 $out/bin/${pname}
      '';
    meta.mainProgram = pname;
    pname = "scheme_template";
    src = ./.;
    version = "0.0.0";
  }
