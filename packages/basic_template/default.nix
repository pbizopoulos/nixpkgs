{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.bwbasic ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/basic && cp main.bas $out/share/basic/main.bas
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.bwbasic}/bin/bwbasic $out/share/basic/main.bas" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
