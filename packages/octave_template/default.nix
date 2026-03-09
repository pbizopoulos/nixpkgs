{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.octave ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/octave && cp main.m $out/share/octave/main.m
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.octave}/bin/octave-cli $out/share/octave/main.m" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "octave_template";
  src = ./.;
  version = "0.0.0";
}
