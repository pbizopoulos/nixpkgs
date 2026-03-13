{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "echo 'Mojo template (source only)'" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
