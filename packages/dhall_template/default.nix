{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  installPhase = ''
    mkdir -p $out/lib/dhall
    cp main.dhall $out/lib/dhall/
    mkdir -p $out/bin
    makeWrapper ${pkgs.dhall}/bin/dhall $out/bin/${pname} \
      --add-flags "text --file $out/lib/dhall/main.dhall"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
