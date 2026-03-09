{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.algol68g ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/algol68 && cp main.a68 $out/share/algol68/main.a68
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.algol68g}/bin/a68g $out/share/algol68/main.a68" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "algol68_template";
  src = ./.;
  version = "0.0.0";
}
