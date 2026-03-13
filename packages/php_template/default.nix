{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  installPhase = ''
    install -Dm644 main.php $out/bin/${pname}.php
    makeWrapper ${pkgs.php}/bin/php $out/bin/${pname} \
      --add-flags "-d display_errors=1 -d error_reporting=E_ALL $out/bin/${pname}.php"
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
