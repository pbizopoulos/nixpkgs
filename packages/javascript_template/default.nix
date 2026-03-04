{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.nodejs ];
  installPhase = ''
    mkdir -p $out/bin
    cp main.js $out/bin/${pname}.js
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
      --add-flags "$out/bin/${pname}.js"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
