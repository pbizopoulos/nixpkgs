{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.regina ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/rexx && cp main.rexx $out/share/rexx/main.rexx
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.regina}/bin/regina $out/share/rexx/main.rexx" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "rexx_template";
  src = ./.;
  version = "0.0.0";
}
