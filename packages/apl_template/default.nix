{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.gnuapl ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/apl && cp main.apl $out/share/apl/main.apl
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.gnuapl}/bin/apl --script --OFF -f $out/share/apl/main.apl" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "apl_template";
  src = ./.;
  version = "0.0.0";
}
