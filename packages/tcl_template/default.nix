{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.tcl
    ];
    installPhase = ''
          mkdir -p $out/bin
          cat <<EOF > $out/bin/${pname}
      #!/usr/bin/env bash
      ${pkgs.tcl}/bin/tclsh ${./.}/main.tcl
      EOF
          chmod 755 $out/bin/${pname}
      '';
    meta.mainProgram = pname;
    pname = "tcl_template";
    src = ./.;
    version = "0.0.0";
  }
