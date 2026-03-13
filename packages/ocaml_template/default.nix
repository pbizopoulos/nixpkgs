{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.ocaml
  ];
  buildPhase = "ocamlc -o ${pname} main.ml";
  installPhase = "mkdir -p $out/bin && cp ${pname} $out/bin/";
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
