{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.idris2
    ];
    buildPhase = ''
      idris2 main.idr -o ${pname}
      '';
    installPhase = ''
          mkdir -p $out/bin
          cp -r build/exec/* $out/bin/
          mv $out/bin/${pname} $out/bin/${pname}_bin
          cat <<EOF > $out/bin/${pname}
      #!/usr/bin/env bash
      $out/bin/${pname}_bin "\$@"
      EOF
          chmod 755 $out/bin/${pname}
      '';
    meta.mainProgram = pname;
    pname = "idris_template";
    src = ./.;
    version = "0.0.0";
  }
