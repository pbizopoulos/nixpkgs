{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  pname = baseNameOf ./.;
  version = "0.0.0";
  src = ./.;

  nativeBuildInputs = [ pkgs.coffeescript pkgs.makeWrapper ];
  buildInputs = [ pkgs.nodejs ];

  buildPhase = "coffee -c main.coffee";

  doInstallCheck = true;
  installCheckPhase = "${pkgs.nodejs}/bin/node $out/share/main.js >/dev/null";

  installPhase = ''
    install -Dm644 main.js $out/share/main.js
    install -d $out/bin
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
      --add-flags "$out/share/main.js"
  '';

  meta.mainProgram = pname;
}
