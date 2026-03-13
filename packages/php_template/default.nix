{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  installPhase = ''
    mkdir -p $out/bin
    cp main.php $out/bin/${pname}.php
    makeWrapper ${pkgs.php}/bin/php $out/bin/${pname} \
      --add-flags "-d display_errors=1 -d error_reporting=E_ALL $out/bin/${pname}.php"
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
