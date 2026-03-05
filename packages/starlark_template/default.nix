{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.starlark ];
  installPhase = ''
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.starlark}/bin/starlark $out/share/starlark/main.star" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    mkdir -p $out/share/starlark
    cp main.star $out/share/starlark/
  '';
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
