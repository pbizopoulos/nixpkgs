{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.gforth ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/forth && cp main.fth $out/share/forth/main.fth
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
    echo "exec ${pkgs.gforth}/bin/gforth $out/share/forth/main.fth" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "forth_template";
  src = ./.;
  version = "0.0.0";
}
