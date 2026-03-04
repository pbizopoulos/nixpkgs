{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.swift ];
  installPhase = ''
    mkdir -p $out/bin
    cp main.swift $out/bin/${pname}.swift
    makeWrapper ${pkgs.swift}/bin/swift $out/bin/${pname} \
      --add-flags "$out/bin/${pname}.swift"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
