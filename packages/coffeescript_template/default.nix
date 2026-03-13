{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  pname = baseNameOf ./.;
  version = "0.0.0";
  src = ./.;

  nativeBuildInputs = [ pkgs.coffeescript pkgs.makeWrapper ];
  buildInputs = [ pkgs.nodejs ];

  buildPhase = "true";

  doInstallCheck = true;
  installCheckPhase = "${pkgs.nodejs}/bin/node $out/share/main.js >/dev/null";

  installPhase = ''
    install -Dm644 ${./main.coffee} $out/share/main.coffee
    coffee -c -o $out/share $out/share/main.coffee
    install -d $out/bin
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
      --add-flags "$out/share/main.js"
  '';

  meta.mainProgram = pname;
}
