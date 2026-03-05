{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  installPhase = ''
    mkdir -p $out/bin
    cp main.php $out/bin/${pname}.php
    makeWrapper ${pkgs.php}/bin/php $out/bin/${pname} \
      --add-flags "$out/bin/${pname}.php"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
