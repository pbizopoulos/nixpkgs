{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.gforth ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/forth && cp main.fth $out/share/forth/main.fth
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.gforth}/bin/gforth $out/share/forth/main.fth" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
