{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.coffeescript
    pkgs.nodejs
  ];
  buildPhase = ''
    coffee -c main.coffee
  '';
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    ${pkgs.nodejs}/bin/node $out/share/main.js
    EOF
        mkdir -p $out/share
        cp -f main.js $out/share/
        chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
