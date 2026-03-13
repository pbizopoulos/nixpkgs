{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.ocaml
  ];
  buildPhase = "ocamlc -o ${pname} main.ml -warn-error +a";
  installPhase = "install -Dm755 ${pname} $out/bin/${pname}";
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
