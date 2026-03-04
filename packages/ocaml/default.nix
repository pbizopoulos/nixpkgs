{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.ocaml ];
  buildPhase = "ocamlopt -o ocaml main.ml";
  installPhase = "mkdir -p $out/bin && cp ocaml $out/bin/${pname}";
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
